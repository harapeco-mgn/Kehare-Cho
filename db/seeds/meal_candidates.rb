module Seeds
  class MealCandidates
    def self.call
      # 各ジャンルに候補料理名を作成（最低3件以上）

      # 和食
      japanese = Genre.find_by!(key: 'japanese')
      [
        { name: '味噌汁', position: 1 },
        { name: '親子丼', position: 2 },
        { name: '焼き魚', position: 3 },
        { name: '肉じゃが', position: 4 },
        { name: '冷奴', position: 5 }
      ].each do |attrs|
        MealCandidate.find_or_create_by!(genre: japanese, name: attrs[:name]) do |mc|
          mc.position = attrs[:position]
          mc.is_active = true
        end
      end

      # 洋食
      western = Genre.find_by!(key: 'western')
      [
        { name: 'オムライス', position: 1 },
        { name: 'ハンバーグ', position: 2 },
        { name: 'グラタン', position: 3 },
        { name: 'ポトフ', position: 4 },
        { name: 'カルボナーラ', position: 5 }
      ].each do |attrs|
        MealCandidate.find_or_create_by!(genre: western, name: attrs[:name]) do |mc|
          mc.position = attrs[:position]
          mc.is_active = true
        end
      end

      # 中華
      chinese = Genre.find_by!(key: 'chinese')
      [
        { name: '麻婆豆腐', position: 1 },
        { name: 'チャーハン', position: 2 },
        { name: '餃子', position: 3 },
        { name: '青椒肉絲', position: 4 },
        { name: '酸辣湯', position: 5 }
      ].each do |attrs|
        MealCandidate.find_or_create_by!(genre: chinese, name: attrs[:name]) do |mc|
          mc.position = attrs[:position]
          mc.is_active = true
        end
      end

      # 麺
      noodle = Genre.find_by!(key: 'noodle')
      [
        { name: 'ラーメン', position: 1 },
        { name: 'うどん', position: 2 },
        { name: 'そば', position: 3 },
        { name: 'パスタ', position: 4 },
        { name: '焼きそば', position: 5 }
      ].each do |attrs|
        MealCandidate.find_or_create_by!(genre: noodle, name: attrs[:name]) do |mc|
          mc.position = attrs[:position]
          mc.is_active = true
        end
      end

      # 丼
      rice_bowl = Genre.find_by!(key: 'rice_bowl')
      [
        { name: '牛丼', position: 1 },
        { name: '天丼', position: 2 },
        { name: 'カツ丼', position: 3 },
        { name: '海鮮丼', position: 4 },
        { name: '親子丼', position: 5 }
      ].each do |attrs|
        MealCandidate.find_or_create_by!(genre: rice_bowl, name: attrs[:name]) do |mc|
          mc.position = attrs[:position]
          mc.is_active = true
        end
      end

      # スープ
      soup = Genre.find_by!(key: 'soup')
      [
        { name: 'ミネストローネ', position: 1 },
        { name: 'コーンスープ', position: 2 },
        { name: '味噌汁', position: 3 },
        { name: '豚汁', position: 4 },
        { name: 'クラムチャウダー', position: 5 }
      ].each do |attrs|
        MealCandidate.find_or_create_by!(genre: soup, name: attrs[:name]) do |mc|
          mc.position = attrs[:position]
          mc.is_active = true
        end
      end

      # サラダ
      salad = Genre.find_by!(key: 'salad')
      [
        { name: 'シーザーサラダ', position: 1 },
        { name: 'ポテトサラダ', position: 2 },
        { name: 'コールスロー', position: 3 },
        { name: 'グリーンサラダ', position: 4 },
        { name: '春雨サラダ', position: 5 }
      ].each do |attrs|
        MealCandidate.find_or_create_by!(genre: salad, name: attrs[:name]) do |mc|
          mc.position = attrs[:position]
          mc.is_active = true
        end
      end

      # おつまみ
      snack = Genre.find_by!(key: 'snack')
      [
        { name: '枝豆', position: 1 },
        { name: '冷奴', position: 2 },
        { name: '唐揚げ', position: 3 },
        { name: 'ポテトフライ', position: 4 },
        { name: 'チーズ盛り合わせ', position: 5 }
      ].each do |attrs|
        MealCandidate.find_or_create_by!(genre: snack, name: attrs[:name]) do |mc|
          mc.position = attrs[:position]
          mc.is_active = true
        end
      end
    end
  end
end
