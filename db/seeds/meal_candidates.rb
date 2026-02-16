module Seeds
  class MealCandidates
    def self.call
      # MoodTag を key で検索するためのヘルパー
      mood_tags = {
        light: MoodTag.find_by!(key: 'light'),
        rich: MoodTag.find_by!(key: 'rich'),
        warm: MoodTag.find_by!(key: 'warm'),
        hearty: MoodTag.find_by!(key: 'hearty'),
        healthy: MoodTag.find_by!(key: 'healthy'),
        easy: MoodTag.find_by!(key: 'easy')
      }

      # 和食
      japanese = Genre.find_by!(key: 'japanese')
      [
        { name: '味噌汁', position: 1, minutes_max: 20, mood: :warm },
        { name: '親子丼', position: 2, minutes_max: 30, mood: nil },
        { name: '焼き魚', position: 3, minutes_max: 20, mood: :healthy },
        { name: '肉じゃが', position: 4, minutes_max: 45, mood: :warm },
        { name: '冷奴', position: 5, minutes_max: 10, mood: :light },
        { name: '天ぷら', position: 6, minutes_max: 60, mood: nil },
        { name: '筑前煮', position: 7, minutes_max: 45, mood: :warm },
        { name: '茶碗蒸し', position: 8, minutes_max: 45, mood: :warm },
        { name: '照り焼きチキン', position: 9, minutes_max: 30, mood: :hearty },
        { name: '豚の生姜焼き', position: 10, minutes_max: 20, mood: :hearty },
        { name: 'さばの味噌煮', position: 11, minutes_max: 30, mood: :warm },
        { name: 'きんぴらごぼう', position: 12, minutes_max: 20, mood: :healthy },
        { name: 'かぼちゃの煮物', position: 13, minutes_max: 30, mood: :warm },
        { name: 'だし巻き卵', position: 14, minutes_max: 20, mood: nil },
        { name: '納豆ごはん', position: 15, minutes_max: 10, mood: :easy },
        { name: 'お茶漬け', position: 16, minutes_max: 10, mood: :easy },
        { name: 'おでん', position: 17, minutes_max: 60, mood: :warm },
        { name: 'ぶり大根', position: 18, minutes_max: 45, mood: :warm },
        { name: '煮魚', position: 19, minutes_max: 30, mood: :warm },
        { name: 'とんかつ', position: 20, minutes_max: 30, mood: :hearty }
      ].each do |attrs|
        mood_tag = attrs[:mood] ? mood_tags[attrs[:mood]] : nil
        mc = MealCandidate.find_or_create_by!(genre: japanese, name: attrs[:name]) do |m|
          m.position = attrs[:position]
          m.is_active = true
        end
        mc.update!(
          cook_context: :self_cook,
          minutes_max: attrs[:minutes_max],
          mood_tag: mood_tag
        )
      end

      # 洋食
      western = Genre.find_by!(key: 'western')
      [
        { name: 'オムライス', position: 1, minutes_max: 30, mood: nil },
        { name: 'ハンバーグ', position: 2, minutes_max: 30, mood: :hearty },
        { name: 'グラタン', position: 3, minutes_max: 45, mood: :rich },
        { name: 'ポトフ', position: 4, minutes_max: 60, mood: :warm },
        { name: 'カルボナーラ', position: 5, minutes_max: 20, mood: :rich },
        { name: 'ビーフシチュー', position: 6, minutes_max: 60, mood: :warm },
        { name: 'クリームシチュー', position: 7, minutes_max: 45, mood: :warm },
        { name: 'ピザトースト', position: 8, minutes_max: 10, mood: :easy },
        { name: 'ドリア', position: 9, minutes_max: 45, mood: :rich },
        { name: 'ミートソーススパゲティ', position: 10, minutes_max: 30, mood: :hearty },
        { name: 'ナポリタン', position: 11, minutes_max: 20, mood: nil },
        { name: 'ペペロンチーノ', position: 12, minutes_max: 20, mood: :light },
        { name: 'フライドチキン', position: 13, minutes_max: 30, mood: :hearty },
        { name: 'ローストビーフ', position: 14, minutes_max: 60, mood: :hearty },
        { name: 'コロッケ', position: 15, minutes_max: 30, mood: nil },
        { name: 'エビフライ', position: 16, minutes_max: 30, mood: :hearty },
        { name: 'ポークソテー', position: 17, minutes_max: 20, mood: :hearty },
        { name: 'チキンソテー', position: 18, minutes_max: 20, mood: :hearty },
        { name: 'ラザニア', position: 19, minutes_max: 60, mood: :rich },
        { name: 'キッシュ', position: 20, minutes_max: 45, mood: :rich }
      ].each do |attrs|
        mood_tag = attrs[:mood] ? mood_tags[attrs[:mood]] : nil
        mc = MealCandidate.find_or_create_by!(genre: western, name: attrs[:name]) do |m|
          m.position = attrs[:position]
          m.is_active = true
        end
        mc.update!(
          cook_context: :self_cook,
          minutes_max: attrs[:minutes_max],
          mood_tag: mood_tag
        )
      end

      # 中華
      chinese = Genre.find_by!(key: 'chinese')
      [
        { name: '麻婆豆腐', position: 1, minutes_max: 30, mood: :rich },
        { name: 'チャーハン', position: 2, minutes_max: 20, mood: nil },
        { name: '餃子', position: 3, minutes_max: 30, mood: :hearty },
        { name: '青椒肉絲', position: 4, minutes_max: 20, mood: nil },
        { name: '酸辣湯', position: 5, minutes_max: 20, mood: :warm },
        { name: 'エビチリ', position: 6, minutes_max: 30, mood: :rich },
        { name: '回鍋肉', position: 7, minutes_max: 20, mood: :hearty },
        { name: '八宝菜', position: 8, minutes_max: 20, mood: nil },
        { name: '棒棒鶏', position: 9, minutes_max: 30, mood: :light },
        { name: '春巻き', position: 10, minutes_max: 30, mood: :hearty },
        { name: 'よだれ鶏', position: 11, minutes_max: 30, mood: :rich },
        { name: '中華丼', position: 12, minutes_max: 20, mood: nil },
        { name: '天津飯', position: 13, minutes_max: 20, mood: nil },
        { name: '担々麺', position: 14, minutes_max: 30, mood: :rich },
        { name: '小籠包', position: 15, minutes_max: 45, mood: nil },
        { name: 'ワンタンスープ', position: 16, minutes_max: 20, mood: :warm },
        { name: 'ニラ玉', position: 17, minutes_max: 20, mood: :easy },
        { name: 'ホイコーロー', position: 18, minutes_max: 20, mood: :hearty },
        { name: 'ユーリンチー', position: 19, minutes_max: 30, mood: :light },
        { name: 'チンジャオロース', position: 20, minutes_max: 20, mood: nil }
      ].each do |attrs|
        mood_tag = attrs[:mood] ? mood_tags[attrs[:mood]] : nil
        mc = MealCandidate.find_or_create_by!(genre: chinese, name: attrs[:name]) do |m|
          m.position = attrs[:position]
          m.is_active = true
        end
        mc.update!(
          cook_context: :self_cook,
          minutes_max: attrs[:minutes_max],
          mood_tag: mood_tag
        )
      end

      # 麺
      noodle = Genre.find_by!(key: 'noodle')
      [
        { name: 'ラーメン', position: 1, minutes_max: 30, mood: :warm },
        { name: 'うどん', position: 2, minutes_max: 20, mood: nil },
        { name: 'そば', position: 3, minutes_max: 20, mood: nil },
        { name: 'パスタ', position: 4, minutes_max: 20, mood: nil },
        { name: '焼きそば', position: 5, minutes_max: 20, mood: nil },
        { name: 'きつねうどん', position: 6, minutes_max: 20, mood: :warm },
        { name: 'たぬきそば', position: 7, minutes_max: 20, mood: :warm },
        { name: 'カレーうどん', position: 8, minutes_max: 30, mood: :warm },
        { name: '冷やし中華', position: 9, minutes_max: 20, mood: :light },
        { name: 'つけ麺', position: 10, minutes_max: 30, mood: :hearty },
        { name: 'そうめん', position: 11, minutes_max: 10, mood: :light },
        { name: 'ざるそば', position: 12, minutes_max: 10, mood: :light },
        { name: 'とんこつラーメン', position: 13, minutes_max: 30, mood: :rich },
        { name: '味噌ラーメン', position: 14, minutes_max: 30, mood: :rich },
        { name: '醤油ラーメン', position: 15, minutes_max: 30, mood: :warm },
        { name: 'フォー', position: 16, minutes_max: 20, mood: :light },
        { name: 'ビーフン', position: 17, minutes_max: 20, mood: :light },
        { name: 'パッタイ', position: 18, minutes_max: 20, mood: nil },
        { name: 'まぜそば', position: 19, minutes_max: 20, mood: :rich },
        { name: 'あんかけ焼きそば', position: 20, minutes_max: 30, mood: :warm }
      ].each do |attrs|
        mood_tag = attrs[:mood] ? mood_tags[attrs[:mood]] : nil
        mc = MealCandidate.find_or_create_by!(genre: noodle, name: attrs[:name]) do |m|
          m.position = attrs[:position]
          m.is_active = true
        end
        mc.update!(
          cook_context: :self_cook,
          minutes_max: attrs[:minutes_max],
          mood_tag: mood_tag
        )
      end

      # 丼
      rice_bowl = Genre.find_by!(key: 'rice_bowl')
      [
        { name: '牛丼', position: 1, minutes_max: 20, mood: :hearty },
        { name: '天丼', position: 2, minutes_max: 45, mood: :hearty },
        { name: 'カツ丼', position: 3, minutes_max: 30, mood: :hearty },
        { name: '海鮮丼', position: 4, minutes_max: 20, mood: :light },
        { name: '親子丼', position: 5, minutes_max: 20, mood: nil },
        { name: '豚丼', position: 6, minutes_max: 20, mood: :hearty },
        { name: 'ネギトロ丼', position: 7, minutes_max: 10, mood: :light },
        { name: 'うな丼', position: 8, minutes_max: 30, mood: :hearty },
        { name: 'そぼろ丼', position: 9, minutes_max: 20, mood: nil },
        { name: 'ロコモコ丼', position: 10, minutes_max: 30, mood: :hearty },
        { name: '中華丼', position: 11, minutes_max: 20, mood: nil },
        { name: 'ビビンバ丼', position: 12, minutes_max: 30, mood: :rich },
        { name: 'アボカド丼', position: 13, minutes_max: 10, mood: :healthy },
        { name: 'まぐろ丼', position: 14, minutes_max: 10, mood: :light },
        { name: 'サーモン丼', position: 15, minutes_max: 10, mood: :light },
        { name: '鉄火丼', position: 16, minutes_max: 10, mood: :light },
        { name: 'ステーキ丼', position: 17, minutes_max: 30, mood: :hearty },
        { name: '焼き鳥丼', position: 18, minutes_max: 30, mood: :hearty },
        { name: 'エビ天丼', position: 19, minutes_max: 45, mood: :hearty },
        { name: '照り焼きチキン丼', position: 20, minutes_max: 30, mood: :hearty }
      ].each do |attrs|
        mood_tag = attrs[:mood] ? mood_tags[attrs[:mood]] : nil
        mc = MealCandidate.find_or_create_by!(genre: rice_bowl, name: attrs[:name]) do |m|
          m.position = attrs[:position]
          m.is_active = true
        end
        mc.update!(
          cook_context: :self_cook,
          minutes_max: attrs[:minutes_max],
          mood_tag: mood_tag
        )
      end

      # スープ
      soup = Genre.find_by!(key: 'soup')
      [
        { name: 'ミネストローネ', position: 1, minutes_max: 30, mood: :warm },
        { name: 'コーンスープ', position: 2, minutes_max: 20, mood: :warm },
        { name: '味噌汁', position: 3, minutes_max: 20, mood: :warm },
        { name: '豚汁', position: 4, minutes_max: 30, mood: :warm },
        { name: 'クラムチャウダー', position: 5, minutes_max: 30, mood: :warm },
        { name: 'オニオンスープ', position: 6, minutes_max: 45, mood: :warm },
        { name: 'トマトスープ', position: 7, minutes_max: 20, mood: :warm },
        { name: 'かぼちゃスープ', position: 8, minutes_max: 30, mood: :warm },
        { name: 'きのこスープ', position: 9, minutes_max: 20, mood: :warm },
        { name: '卵スープ', position: 10, minutes_max: 10, mood: :warm },
        { name: 'わかめスープ', position: 11, minutes_max: 10, mood: :warm },
        { name: 'コンソメスープ', position: 12, minutes_max: 20, mood: :warm },
        { name: 'ボルシチ', position: 13, minutes_max: 60, mood: :warm },
        { name: 'ガスパチョ', position: 14, minutes_max: 20, mood: :light },
        { name: 'けんちん汁', position: 15, minutes_max: 30, mood: :warm },
        { name: 'お吸い物', position: 16, minutes_max: 10, mood: :warm },
        { name: 'あさりの味噌汁', position: 17, minutes_max: 20, mood: :warm },
        { name: 'じゃがいもスープ', position: 18, minutes_max: 30, mood: :warm },
        { name: 'レンズ豆スープ', position: 19, minutes_max: 45, mood: :warm },
        { name: '白菜スープ', position: 20, minutes_max: 20, mood: :warm }
      ].each do |attrs|
        mood_tag = attrs[:mood] ? mood_tags[attrs[:mood]] : nil
        mc = MealCandidate.find_or_create_by!(genre: soup, name: attrs[:name]) do |m|
          m.position = attrs[:position]
          m.is_active = true
        end
        mc.update!(
          cook_context: :self_cook,
          minutes_max: attrs[:minutes_max],
          mood_tag: mood_tag
        )
      end

      # サラダ
      salad = Genre.find_by!(key: 'salad')
      [
        { name: 'シーザーサラダ', position: 1, minutes_max: 20, mood: :healthy },
        { name: 'ポテトサラダ', position: 2, minutes_max: 30, mood: nil },
        { name: 'コールスロー', position: 3, minutes_max: 20, mood: :light },
        { name: 'グリーンサラダ', position: 4, minutes_max: 10, mood: :healthy },
        { name: '春雨サラダ', position: 5, minutes_max: 20, mood: :light },
        { name: 'チョレギサラダ', position: 6, minutes_max: 10, mood: :light },
        { name: 'カプレーゼ', position: 7, minutes_max: 10, mood: :light },
        { name: 'ニース風サラダ', position: 8, minutes_max: 20, mood: :healthy },
        { name: '大根サラダ', position: 9, minutes_max: 10, mood: :light },
        { name: 'トマトサラダ', position: 10, minutes_max: 10, mood: :light },
        { name: 'アボカドサラダ', position: 11, minutes_max: 10, mood: :healthy },
        { name: 'ツナサラダ', position: 12, minutes_max: 10, mood: :healthy },
        { name: '豆腐サラダ', position: 13, minutes_max: 10, mood: :healthy },
        { name: 'マカロニサラダ', position: 14, minutes_max: 30, mood: nil },
        { name: 'コブサラダ', position: 15, minutes_max: 20, mood: :healthy },
        { name: 'ごぼうサラダ', position: 16, minutes_max: 20, mood: :healthy },
        { name: 'キャベツサラダ', position: 17, minutes_max: 10, mood: :light },
        { name: '水菜サラダ', position: 18, minutes_max: 10, mood: :light },
        { name: 'きゅうりサラダ', position: 19, minutes_max: 10, mood: :light },
        { name: 'かぼちゃサラダ', position: 20, minutes_max: 30, mood: nil }
      ].each do |attrs|
        mood_tag = attrs[:mood] ? mood_tags[attrs[:mood]] : nil
        mc = MealCandidate.find_or_create_by!(genre: salad, name: attrs[:name]) do |m|
          m.position = attrs[:position]
          m.is_active = true
        end
        mc.update!(
          cook_context: :self_cook,
          minutes_max: attrs[:minutes_max],
          mood_tag: mood_tag
        )
      end

      # おつまみ
      snack = Genre.find_by!(key: 'snack')
      [
        { name: '枝豆', position: 1, minutes_max: 10, mood: :easy },
        { name: '冷奴', position: 2, minutes_max: 10, mood: :light },
        { name: '唐揚げ', position: 3, minutes_max: 30, mood: :hearty },
        { name: 'ポテトフライ', position: 4, minutes_max: 20, mood: :hearty },
        { name: 'チーズ盛り合わせ', position: 5, minutes_max: nil, mood: :easy },
        { name: '揚げ出し豆腐', position: 6, minutes_max: 20, mood: :warm },
        { name: 'ナッツ', position: 7, minutes_max: nil, mood: :easy },
        { name: 'ピクルス', position: 8, minutes_max: nil, mood: :light },
        { name: 'メンマ', position: 9, minutes_max: nil, mood: :light },
        { name: '漬物', position: 10, minutes_max: nil, mood: :light },
        { name: 'たこわさ', position: 11, minutes_max: nil, mood: :light },
        { name: 'いかの塩辛', position: 12, minutes_max: nil, mood: :rich },
        { name: 'アヒージョ', position: 13, minutes_max: 20, mood: :rich },
        { name: 'カマンベールチーズフライ', position: 14, minutes_max: 20, mood: :hearty },
        { name: '焼き鳥', position: 15, minutes_max: 30, mood: :hearty },
        { name: '刺身盛り合わせ', position: 16, minutes_max: nil, mood: :light },
        { name: 'カルパッチョ', position: 17, minutes_max: 10, mood: :light },
        { name: '生ハムメロン', position: 18, minutes_max: nil, mood: :light },
        { name: 'バーニャカウダ', position: 19, minutes_max: 20, mood: :healthy },
        { name: 'エイヒレ', position: 20, minutes_max: nil, mood: :easy }
      ].each do |attrs|
        mood_tag = attrs[:mood] ? mood_tags[attrs[:mood]] : nil
        mc = MealCandidate.find_or_create_by!(genre: snack, name: attrs[:name]) do |m|
          m.position = attrs[:position]
          m.is_active = true
        end
        mc.update!(
          cook_context: :self_cook,
          minutes_max: attrs[:minutes_max],
          mood_tag: mood_tag
        )
      end
    end
  end
end
