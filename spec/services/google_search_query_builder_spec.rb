require 'rails_helper'

RSpec.describe GoogleSearchQueryBuilder do
  describe '#query' do
    context '通常の料理名の場合' do
      it '料理名に「レシピ」を付けてエンコードする' do
        builder = described_class.new('カレー')
        expect(builder.query).to eq(CGI.escape('カレー レシピ'))
      end
    end

    context 'スペースを含む料理名の場合' do
      it '正しくエンコードする' do
        builder = described_class.new('親子 丼')
        expect(builder.query).to eq(CGI.escape('親子 丼 レシピ'))
      end
    end

    context '特殊文字を含む料理名の場合' do
      it '&記号を正しくエンコードする' do
        builder = described_class.new('親子丼&味噌汁')
        expect(builder.query).to eq(CGI.escape('親子丼&味噌汁 レシピ'))
      end

      it '?記号を正しくエンコードする' do
        builder = described_class.new('カレー?')
        expect(builder.query).to eq(CGI.escape('カレー? レシピ'))
      end
    end

    context '日本語を含む料理名の場合' do
      it '正しくエンコードする' do
        builder = described_class.new('麻婆豆腐')
        expect(builder.query).to eq(CGI.escape('麻婆豆腐 レシピ'))
      end
    end
  end

  describe '#url' do
    it 'Google検索のURLを生成する' do
      builder = described_class.new('カレー')
      expected_url = "https://www.google.com/search?q=#{CGI.escape('カレー レシピ')}"
      expect(builder.url).to eq(expected_url)
    end

    it 'BASE_URLを含む' do
      builder = described_class.new('パスタ')
      expect(builder.url).to start_with('https://www.google.com/search')
    end

    it 'クエリパラメータqを含む' do
      builder = described_class.new('ラーメン')
      expect(builder.url).to include('?q=')
    end

    context '複雑な料理名の場合' do
      it '正しいURLを生成する' do
        builder = described_class.new('親子丼 & 味噌汁')
        expected_url = "https://www.google.com/search?q=#{CGI.escape('親子丼 & 味噌汁 レシピ')}"
        expect(builder.url).to eq(expected_url)
      end
    end
  end
end
