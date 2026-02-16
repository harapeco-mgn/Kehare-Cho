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
        { name: '冷奴', position: 5 },
        { name: '天ぷら', position: 6 },
        { name: '筑前煮', position: 7 },
        { name: '茶碗蒸し', position: 8 },
        { name: '照り焼きチキン', position: 9 },
        { name: '豚の生姜焼き', position: 10 },
        { name: 'さばの味噌煮', position: 11 },
        { name: 'きんぴらごぼう', position: 12 },
        { name: 'かぼちゃの煮物', position: 13 },
        { name: 'だし巻き卵', position: 14 },
        { name: '納豆ごはん', position: 15 },
        { name: 'お茶漬け', position: 16 },
        { name: 'おでん', position: 17 },
        { name: 'ぶり大根', position: 18 },
        { name: '煮魚', position: 19 },
        { name: 'とんかつ', position: 20 }
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
        { name: 'カルボナーラ', position: 5 },
        { name: 'ビーフシチュー', position: 6 },
        { name: 'クリームシチュー', position: 7 },
        { name: 'ピザトースト', position: 8 },
        { name: 'ドリア', position: 9 },
        { name: 'ミートソーススパゲティ', position: 10 },
        { name: 'ナポリタン', position: 11 },
        { name: 'ペペロンチーノ', position: 12 },
        { name: 'フライドチキン', position: 13 },
        { name: 'ローストビーフ', position: 14 },
        { name: 'コロッケ', position: 15 },
        { name: 'エビフライ', position: 16 },
        { name: 'ポークソテー', position: 17 },
        { name: 'チキンソテー', position: 18 },
        { name: 'ラザニア', position: 19 },
        { name: 'キッシュ', position: 20 }
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
        { name: '酸辣湯', position: 5 },
        { name: 'エビチリ', position: 6 },
        { name: '回鍋肉', position: 7 },
        { name: '八宝菜', position: 8 },
        { name: '棒棒鶏', position: 9 },
        { name: '春巻き', position: 10 },
        { name: 'よだれ鶏', position: 11 },
        { name: '中華丼', position: 12 },
        { name: '天津飯', position: 13 },
        { name: '担々麺', position: 14 },
        { name: '小籠包', position: 15 },
        { name: 'ワンタンスープ', position: 16 },
        { name: 'ニラ玉', position: 17 },
        { name: 'ホイコーロー', position: 18 },
        { name: 'ユーリンチー', position: 19 },
        { name: 'チンジャオロース', position: 20 }
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
        { name: '焼きそば', position: 5 },
        { name: 'きつねうどん', position: 6 },
        { name: 'たぬきそば', position: 7 },
        { name: 'カレーうどん', position: 8 },
        { name: '冷やし中華', position: 9 },
        { name: 'つけ麺', position: 10 },
        { name: 'そうめん', position: 11 },
        { name: 'ざるそば', position: 12 },
        { name: 'とんこつラーメン', position: 13 },
        { name: '味噌ラーメン', position: 14 },
        { name: '醤油ラーメン', position: 15 },
        { name: 'フォー', position: 16 },
        { name: 'ビーフン', position: 17 },
        { name: 'パッタイ', position: 18 },
        { name: 'まぜそば', position: 19 },
        { name: 'あんかけ焼きそば', position: 20 }
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
        { name: '親子丼', position: 5 },
        { name: '豚丼', position: 6 },
        { name: 'ネギトロ丼', position: 7 },
        { name: 'うな丼', position: 8 },
        { name: 'そぼろ丼', position: 9 },
        { name: 'ロコモコ丼', position: 10 },
        { name: '中華丼', position: 11 },
        { name: 'ビビンバ丼', position: 12 },
        { name: 'アボカド丼', position: 13 },
        { name: 'まぐろ丼', position: 14 },
        { name: 'サーモン丼', position: 15 },
        { name: '鉄火丼', position: 16 },
        { name: 'ステーキ丼', position: 17 },
        { name: '焼き鳥丼', position: 18 },
        { name: 'エビ天丼', position: 19 },
        { name: '照り焼きチキン丼', position: 20 }
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
        { name: 'クラムチャウダー', position: 5 },
        { name: 'オニオンスープ', position: 6 },
        { name: 'トマトスープ', position: 7 },
        { name: 'かぼちゃスープ', position: 8 },
        { name: 'きのこスープ', position: 9 },
        { name: '卵スープ', position: 10 },
        { name: 'わかめスープ', position: 11 },
        { name: 'コンソメスープ', position: 12 },
        { name: 'ボルシチ', position: 13 },
        { name: 'ガスパチョ', position: 14 },
        { name: 'けんちん汁', position: 15 },
        { name: 'お吸い物', position: 16 },
        { name: 'あさりの味噌汁', position: 17 },
        { name: 'じゃがいもスープ', position: 18 },
        { name: 'レンズ豆スープ', position: 19 },
        { name: '白菜スープ', position: 20 }
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
        { name: '春雨サラダ', position: 5 },
        { name: 'チョレギサラダ', position: 6 },
        { name: 'カプレーゼ', position: 7 },
        { name: 'ニース風サラダ', position: 8 },
        { name: '大根サラダ', position: 9 },
        { name: 'トマトサラダ', position: 10 },
        { name: 'アボカドサラダ', position: 11 },
        { name: 'ツナサラダ', position: 12 },
        { name: '豆腐サラダ', position: 13 },
        { name: 'マカロニサラダ', position: 14 },
        { name: 'コブサラダ', position: 15 },
        { name: 'ごぼうサラダ', position: 16 },
        { name: 'キャベツサラダ', position: 17 },
        { name: '水菜サラダ', position: 18 },
        { name: 'きゅうりサラダ', position: 19 },
        { name: 'かぼちゃサラダ', position: 20 }
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
        { name: 'チーズ盛り合わせ', position: 5 },
        { name: '揚げ出し豆腐', position: 6 },
        { name: 'ナッツ', position: 7 },
        { name: 'ピクルス', position: 8 },
        { name: 'メンマ', position: 9 },
        { name: '漬物', position: 10 },
        { name: 'たこわさ', position: 11 },
        { name: 'いかの塩辛', position: 12 },
        { name: 'アヒージョ', position: 13 },
        { name: 'カマンベールチーズフライ', position: 14 },
        { name: '焼き鳥', position: 15 },
        { name: '刺身盛り合わせ', position: 16 },
        { name: 'カルパッチョ', position: 17 },
        { name: '生ハムメロン', position: 18 },
        { name: 'バーニャカウダ', position: 19 },
        { name: 'エイヒレ', position: 20 }
      ].each do |attrs|
        MealCandidate.find_or_create_by!(genre: snack, name: attrs[:name]) do |mc|
          mc.position = attrs[:position]
          mc.is_active = true
        end
      end
    end
  end
end
