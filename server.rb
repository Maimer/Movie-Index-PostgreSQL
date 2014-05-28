require 'sinatra'
require_relative 'helpers.rb'

get '/' do
  redirect '/movies'
end

get '/movies' do
  @title = "MOVIES INDEX"
  if params[:order] != nil
    @order = params[:order]
  else
    @order = "title"
  end
  if params[:page] != nil
    @page = params[:page].to_i
  else
    @page = 1
  end
  if params[:query] == nil
    @movies = get_movies(@order, @page).to_a
  else
    @movies = search("movies", params[:query])
  end
  erb :'movies/index'
end

get '/movies/:id' do
  @movie = get_movie_detail(params[:id])
  @title = @movie[0]["title"]
  erb :'movies/show'
end

get '/actors' do
  @title = "ACTORS INDEX"
  if params[:page] != nil
    @page = params[:page].to_i
  else
    @page = 1
  end
  if params[:query] == nil
    @actors = get_actors(@page).to_a
  else
    @actors = search("actors", params[:query])
  end
  erb :'actors/index'
end

get '/actors/:id' do
  @actor = get_actor_detail(params[:id])
  @title = @actor[0]["name"]
  erb :'actors/show'
end
