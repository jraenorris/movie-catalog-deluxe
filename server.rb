require 'sinatra'
require 'pg'
require 'uri'
require 'pry'

def db_connection
  begin
    connection = PG.connect(dbname: "movies")
    yield(connection)
  ensure
    connection.close
  end
end

get '/' do
  redirect '/actors'
end

get '/actors' do
  actors_data = db_connection { |conn| conn.exec("SELECT id, name FROM actors ORDER BY name;") }

  erb :'actors/index', locals: { actors: actors_data}
end

get '/actors/:id' do
  id_integer = params["id"].to_i
  actor_info = db_connection { |conn| conn.exec_params("SELECT movies.id AS movie_id, actors.id AS actor_id, actors.name, movies.title, cast_members.character FROM actors
    LEFT JOIN cast_members ON (cast_members.actor_id = actors.id)
    LEFT JOIN movies ON (cast_members.movie_id = movies.id)
    WHERE actors.id = $1;", [id_integer]) }
  erb :'actors/show', locals: { actor_info: actor_info}
end

get '/movies' do
  movies_data = db_connection { |conn| conn.exec("SELECT movies.id, movies.title, movies.year, movies.rating, genres.name, studios.name FROM movies
     LEFT JOIN genres ON (genres.id = movies.genre_id)
     LEFT JOIN studios ON (studios.id = movies.studio_id)
     ORDER BY genres.name;") }
# binding.pry
  erb :'movies/index', locals: { movies: movies_data}
end

get '/movies/:id' do
  id_integer = params["id"].to_i
  movie_info = db_connection { |conn| conn.exec_params("SELECT movies.id AS movie_id, actors.id AS actor_id, movies.title, genres.name AS genre, studios.name AS studio, actors.name, cast_members.character FROM movies
    LEFT JOIN cast_members ON movies.id = cast_members.movie_id
    LEFT JOIN genres ON movies.genre_id = genres.id
    LEFT JOIN studios ON movies.studio_id = studios.id
    LEFT JOIN actors ON cast_members.actor_id = actors.id
    WHERE movies.id = $1;", [id_integer]) }
# binding.pry
  erb :'movies/show', locals: {movie_info: movie_info}
end
