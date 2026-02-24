require 'rails_helper'

RSpec.describe GoogleMapsQueryBuilder do
  describe "#url" do
    context "ジャンルIDのみ指定した場合" do
      it "Google MapsのURLを返す" do
        genre = Genre.find_or_create_by(key: "japanese") { |g| g.label = "和食" }
        builder = GoogleMapsQueryBuilder.new(genre.id)

        expect(builder.url).to include("https://www.google.com/maps/search/")
        expect(builder.url).to include("api=1")
        expect(builder.url).to include("query=")
      end

      it "URLにジャンル名が含まれる" do
        genre = Genre.find_or_create_by(key: "japanese") { |g| g.label = "和食" }
        builder = GoogleMapsQueryBuilder.new(genre.id)

        expect(builder.url).to include(CGI.escape("和食"))
      end

      it "URLに「惣菜」が含まれる" do
        genre = Genre.find_or_create_by(key: "japanese") { |g| g.label = "和食" }
        builder = GoogleMapsQueryBuilder.new(genre.id)

        expect(builder.url).to include(CGI.escape("惣菜"))
      end

      it "URLに「定食」が含まれる" do
        genre = Genre.find_or_create_by(key: "japanese") { |g| g.label = "和食" }
        builder = GoogleMapsQueryBuilder.new(genre.id)

        expect(builder.url).to include(CGI.escape("定食"))
      end
    end

    context "ジャンルIDと気分タグIDを指定した場合" do
      it "URLに気分タグのキーワードが含まれる（light → さっぱり）" do
        genre = Genre.find_or_create_by(key: "japanese") { |g| g.label = "和食" }
        mood = MoodTag.find_or_create_by(key: "light") { |m| m.label = "さっぱり" }
        builder = GoogleMapsQueryBuilder.new(genre.id, mood.id)

        expect(builder.url).to include(CGI.escape("さっぱり"))
      end

      it "URLに気分タグのキーワードが含まれる（rich → こってり）" do
        genre = Genre.find_or_create_by(key: "japanese") { |g| g.label = "和食" }
        mood = MoodTag.find_or_create_by(key: "rich") { |m| m.label = "こってり" }
        builder = GoogleMapsQueryBuilder.new(genre.id, mood.id)

        expect(builder.url).to include(CGI.escape("こってり"))
      end

      it "URLに気分タグのキーワードが含まれる（warm → あったかい）" do
        genre = Genre.find_or_create_by(key: "japanese") { |g| g.label = "和食" }
        mood = MoodTag.find_or_create_by(key: "warm") { |m| m.label = "あったかい" }
        builder = GoogleMapsQueryBuilder.new(genre.id, mood.id)

        expect(builder.url).to include(CGI.escape("あったかい"))
      end

      it "URLに気分タグのキーワードが含まれる（hearty → がっつり）" do
        genre = Genre.find_or_create_by(key: "japanese") { |g| g.label = "和食" }
        mood = MoodTag.find_or_create_by(key: "hearty") { |m| m.label = "がっつり" }
        builder = GoogleMapsQueryBuilder.new(genre.id, mood.id)

        expect(builder.url).to include(CGI.escape("がっつり"))
      end

      it "URLに気分タグのキーワードが含まれる（healthy → ヘルシー）" do
        genre = Genre.find_or_create_by(key: "japanese") { |g| g.label = "和食" }
        mood = MoodTag.find_or_create_by(key: "healthy") { |m| m.label = "ヘルシー" }
        builder = GoogleMapsQueryBuilder.new(genre.id, mood.id)

        expect(builder.url).to include(CGI.escape("ヘルシー"))
      end

      it "URLに気分タグのキーワードが含まれる（easy → 簡単）" do
        genre = Genre.find_or_create_by(key: "japanese") { |g| g.label = "和食" }
        mood = MoodTag.find_or_create_by(key: "easy") { |m| m.label = "簡単" }
        builder = GoogleMapsQueryBuilder.new(genre.id, mood.id)

        expect(builder.url).to include(CGI.escape("簡単"))
      end
    end

    context "存在しないジャンルIDを指定した場合" do
      it "ActiveRecord::RecordNotFoundが発生する" do
        expect {
          GoogleMapsQueryBuilder.new(9999)
        }.to raise_error(ActiveRecord::RecordNotFound)
      end
    end
  end

  describe "#query" do
    it "ジャンル名 + 惣菜 + 定食の文字列を返す" do
      genre = Genre.find_or_create_by(key: "japanese") { |g| g.label = "和食" }
      builder = GoogleMapsQueryBuilder.new(genre.id)

      # CGI.escapeでエンコードされた文字列が返される
      expect(builder.query).to eq(CGI.escape("和食 惣菜 定食"))
    end

    it "気分タグがある場合、キーワードが追加される" do
      genre = Genre.find_or_create_by(key: "japanese") { |g| g.label = "和食" }
      mood = MoodTag.find_or_create_by(key: "hearty") { |m| m.label = "がっつり" }
      builder = GoogleMapsQueryBuilder.new(genre.id, mood.id)

      expect(builder.query).to eq(CGI.escape("和食 惣菜 定食 がっつり"))
    end

    it "特殊文字が正しくエスケープされる" do
      genre = create(:genre, label: "和食&洋食")
      builder = GoogleMapsQueryBuilder.new(genre.id)

      # &が%26にエスケープされる
      expect(builder.query).to include("%26")
    end
  end
end
