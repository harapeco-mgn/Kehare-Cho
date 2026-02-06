module Seeds
  class MoodTags
    def self.call
      MoodTag.find_or_create_by!(key: 'light') do |mood|
        mood.label = 'さっぱり'
        mood.position = 1
        mood.is_active = true
      end

      MoodTag.find_or_create_by!(key: 'rich') do |mood|
        mood.label = 'こってり'
        mood.position = 2
        mood.is_active = true
      end

      MoodTag.find_or_create_by!(key: 'warm') do |mood|
        mood.label = 'あったかい'
        mood.position = 3
        mood.is_active = true
      end

      MoodTag.find_or_create_by!(key: 'hearty') do |mood|
        mood.label = 'がっつり'
        mood.position = 4
        mood.is_active = true
      end

      MoodTag.find_or_create_by!(key: 'healthy') do |mood|
        mood.label = 'ヘルシー'
        mood.position = 5
        mood.is_active = true
      end

      MoodTag.find_or_create_by!(key: 'easy') do |mood|
        mood.label = '簡単'
        mood.position = 6
        mood.is_active = true
      end
    end
  end
end
