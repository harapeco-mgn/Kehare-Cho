module Seeds
  class Genres
    def self.call
      Genre.find_or_create_by!(key: 'japanese') do |genre|
        genre.label = '和食'
        genre.position = 1
        genre.is_active = true
      end

      Genre.find_or_create_by!(key: 'western') do |genre|
        genre.label = '洋食'
        genre.position = 2
        genre.is_active = true
      end

      Genre.find_or_create_by!(key: 'chinese') do |genre|
        genre.label = '中華'
        genre.position = 3
        genre.is_active = true
      end

      Genre.find_or_create_by!(key: 'noodle') do |genre|
        genre.label = '麺'
        genre.position = 4
        genre.is_active = true
      end

      Genre.find_or_create_by!(key: 'rice_bowl') do |genre|
        genre.label = '丼'
        genre.position = 5
        genre.is_active = true
      end

      Genre.find_or_create_by!(key: 'soup') do |genre|
        genre.label = 'スープ'
        genre.position = 6
        genre.is_active = true
      end

      Genre.find_or_create_by!(key: 'salad') do |genre|
        genre.label = 'サラダ'
        genre.position = 7
        genre.is_active = true
      end

      Genre.find_or_create_by!(key: 'snack') do |genre|
        genre.label = 'おつまみ'
        genre.position = 8
        genre.is_active = true
      end
    end
  end
end
