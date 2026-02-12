class GoogleSearchQueryBuilder
  BASE_URL = "https://www.google.com/search"

  def initialize(meal_name)
    @meal_name = meal_name
  end

  def url
    "#{BASE_URL}?q=#{query}"
  end

  def query
    CGI.escape("#{@meal_name} レシピ")
  end
end
