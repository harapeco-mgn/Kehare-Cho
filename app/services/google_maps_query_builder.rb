class GoogleMapsQueryBuilder
    BASE_URL = "https://www.google.com/maps/search/"
    MOOD_KEYWORDS = {
      "light"   => "さっぱり",
      "rich"    => "こってり",
      "warm"    => "あったかい",
      "hearty"  => "がっつり",
      "healthy" => "ヘルシー",
      "easy"    => "簡単"
    }.freeze

    def initialize(genre_id, mood_tag_id = nil)
      @genre = Genre.find(genre_id)
      @mood = MoodTag.find(mood_tag_id) if mood_tag_id
    end

    def url
      "#{BASE_URL}?api=1&query=#{query}"
    end

    def query
      keywords = [ @genre.label, "惣菜", "定食" ]
      keywords << mood_keyword if @mood
      CGI.escape(keywords.join(" "))
    end

    private

    def mood_keyword
      MOOD_KEYWORDS[@mood.key]
    end
end
