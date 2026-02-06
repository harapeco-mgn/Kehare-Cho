module Seeds
  class HareTags
    def self.call
      HareTag.find_or_create_by!(key: 'homemade_meal') do |tag|
        tag.label = '自炊'
        tag.position = 1
        tag.is_active = true
      end

      HareTag.find_or_create_by!(key: 'seasonal_ingredient') do |tag|
        tag.label = '旬の食材'
        tag.position = 2
        tag.is_active = true
      end

      HareTag.find_or_create_by!(key: 'new_recipe') do |tag|
        tag.label = '新レシピ挑戦'
        tag.position = 3
        tag.is_active = true
      end

      HareTag.find_or_create_by!(key: 'colorful_dish') do |tag|
        tag.label = '彩り豊か'
        tag.position = 4
        tag.is_active = true
      end

      HareTag.find_or_create_by!(key: 'plating') do |tag|
        tag.label = '盛り付け工夫'
        tag.position = 5
        tag.is_active = true
      end

      HareTag.find_or_create_by!(key: 'local_specialty') do |tag|
        tag.label = '地元の名産'
        tag.position = 6
        tag.is_active = true
      end

      HareTag.find_or_create_by!(key: 'unusual_ingredient') do |tag|
        tag.label = '珍しい食材'
        tag.position = 7
        tag.is_active = true
      end

      HareTag.find_or_create_by!(key: 'cooking_tool') do |tag|
        tag.label = '調理器具活用'
        tag.position = 8
        tag.is_active = true
      end

      HareTag.find_or_create_by!(key: 'preserved_food') do |tag|
        tag.label = '保存食作り'
        tag.position = 9
        tag.is_active = true
      end

      HareTag.find_or_create_by!(key: 'outdoor_meal') do |tag|
        tag.label = '外食・テイクアウト'
        tag.position = 10
        tag.is_active = true
      end
    end
  end
end
