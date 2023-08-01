class RecommendationEngine
  def initialize(favorite_movies)
    @favorite_movies = favorite_movies
  end

  def recommendations
    movie_titles = @favorite_movies.pluck(:title)
    common_genres = Movie.where(title: movie_titles).group(:genre).limit(3).order(Arel.sql('COUNT(*) DESC')).pluck(:genre)
    top_movies = Movie.where(genre: common_genres).order(rating: :desc).limit(10)
    return top_movies
  end
end
