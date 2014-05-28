require 'pg'
require 'pry'

def db_connection
  begin
    connection = PG.connect(dbname: 'movies')

    yield(connection)

  ensure
    connection.close
  end
end

def get_movies(order, page)
  db_connection do |conn|
    query = "SELECT movies.title, movies.year, movies.rating, movies.id, genres.name AS genre, studios.name
             AS studio
             FROM movies
               JOIN genres ON movies.genre_id = genres.id
               JOIN studios ON movies.studio_id = studios.id
             ORDER BY movies.#{order}
             LIMIT 20
             OFFSET #{(page * 20) - 20}"
    conn.exec(query)
  end
end

def get_movie_detail(id)
  db_connection do |conn|
    query = "SELECT movies.title, movies.year, genres.name AS genre, studios.name AS studio, actors.id, actors.name
             AS actor, cast_members.character
             FROM movies
               INNER JOIN genres ON movies.genre_id = genres.id
               INNER JOIN studios ON movies.studio_id = studios.id
               JOIN cast_members ON movies.id = cast_members.movie_id
               JOIN actors ON cast_members.actor_id = actors.id
             WHERE movies.id = #{id}"
    conn.exec(query)
  end
end

def get_actors(page)
  db_connection do |conn|
    query = "SELECT actors.name, actors.id, count(*) FROM actors
               JOIN cast_members ON actors.id = cast_members.actor_id
               JOIN movies ON movies.id = cast_members.movie_id
             GROUP BY actors.id
             ORDER BY actors.name
             LIMIT 20
             OFFSET #{(page * 20) - 20}"
    conn.exec(query)
  end
end

def get_actor_detail(id)
  db_connection do |conn|
    query = "SELECT actors.name, movies.title, movies.id, cast_members.character
               FROM actors
               JOIN cast_members ON actors.id = cast_members.actor_id
               JOIN movies ON movies.id = cast_members.movie_id
             WHERE actors.id = #{id}"
    conn.exec(query)
  end
end

def search(type, terms)
  db_connection do |conn|
    if type == "movies"
      query = "SELECT movies.title, movies.year, movies.rating, movies.id, movies.synopsis, genres.name AS genre, studios.name
               AS studio
               FROM movies
                 JOIN genres ON movies.genre_id = genres.id
                 JOIN studios ON movies.studio_id = studios.id
               WHERE movies.title ILIKE $1
               ORDER BY movies.title"
    elsif type == "actors"
      query = "SELECT actors.name, actors.id FROM actors
               WHERE actors.name ILIKE $1
               ORDER BY actors.name"
    end
    conn.exec_params(query, ["%#{terms}%"])
  end
end
