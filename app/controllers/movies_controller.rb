class MoviesController < ApplicationController
  def index
    @movies = Movie.all

    if @movies.empty?
      render json: { message: "No movies found." }, status: :not_found
    else
      render json: @movies
    end
  end

  def recommendations
    begin
      user = User.find(params[:user_id])

      favorite_movies = User.find(params[:user_id]).favorites
      @recommendations = RecommendationEngine.new(favorite_movies).recommendations
      render json: @recommendations
    rescue ActiveRecord::RecordNotFound => e
      render json: { error: "User not found." }, status: :not_found
    end
  end

  def user_rented_movies
    begin
      user = User.find(params[:user_id])

      @rented = User.find(params[:user_id]).rented
      render json: @rented
    rescue ActiveRecord::RecordNotFound => e
      render json: { error: "User not found." }, status: :not_found
    end
  end

  def rent
    begin
      user = User.find(params[:user_id])
      movie = Movie.find(params[:id])

      if movie.available_copies > 0
        if Rental.exists?(user_id: user.id, movie_id: movie.id)
          render json: { error: "This movie is already rented by the user." }, status: :unprocessable_entity
        else
          movie.available_copies -= 1
          movie.save
          user.rented << movie
          render json: movie
        end
      else
        render json: { error: "No available copies for rental." }, status: :unprocessable_entity
      end
    rescue ActiveRecord::RecordNotFound => e
      render json: { error: "User or movie not found." }, status: :not_found
    end
  end

end
