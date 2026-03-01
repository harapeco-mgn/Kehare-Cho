# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ApplicationHelper, type: :helper do
  describe '#linkify_body' do
    context 'URLが含まれない場合' do
      it 'テキストをそのまま返す' do
        result = helper.linkify_body('今日はカレーを作りました')
        expect(result).to eq('今日はカレーを作りました')
      end
    end

    context 'URLが含まれる場合' do
      it 'URLを <a> タグに変換する' do
        result = helper.linkify_body('参考にしたレシピ: https://example.com/recipe')
        expect(result).to include('<a ')
        expect(result).to include('href="https://example.com/recipe"')
      end

      it 'リンクが新しいタブで開く属性を持つ' do
        result = helper.linkify_body('https://example.com')
        expect(result).to include('target="_blank"')
        expect(result).to include('rel="noopener noreferrer"')
      end

      it 'リンクにアクセントカラーのクラスが付く' do
        result = helper.linkify_body('https://example.com')
        expect(result).to include('class="text-[#C87941]')
      end
    end

    context 'XSS 対策' do
      it '<script> タグをエスケープする' do
        result = helper.linkify_body('<script>alert("xss")</script>')
        expect(result).not_to include('<script>')
        expect(result).to include('&lt;script&gt;')
      end

      it '<a> タグ以外の HTML タグを除去する' do
        result = helper.linkify_body('<b>太字</b>テキスト')
        expect(result).not_to include('<b>')
        expect(result).to include('太字')
      end

      it 'href 以外の危険な属性は含まれない' do
        # onload などのイベントハンドラが残らないことを確認
        result = helper.linkify_body('https://example.com')
        expect(result).not_to include('onload=')
        expect(result).not_to include('onclick=')
      end
    end
  end

  describe '#x_share_text' do
    let(:entry) { build(:hare_entry, occurred_on: Date.new(2026, 3, 1), body: '今日はカレーを作りました') }

    it '本文・日付・ハッシュタグを含むテキストを返す' do
      result = helper.x_share_text(entry)
      expect(result).to include('今日はカレーを作りました')
      expect(result).to include('2026年3月1日のハレ記録')
      expect(result).to include('#ケハレ帖')
    end

    context '本文が100文字を超える場合' do
      let(:long_body) { 'あ' * 120 }
      let(:entry) { build(:hare_entry, occurred_on: Date.new(2026, 3, 1), body: long_body) }

      it '100文字で切り詰める（truncate の省略記号込み）' do
        result = helper.x_share_text(entry)
        body_part = result.split("\n\n").first
        expect(body_part.length).to be <= 103 # 100文字 + "..."
      end
    end

    context '本文に改行が含まれる場合' do
      let(:entry) { build(:hare_entry, occurred_on: Date.new(2026, 3, 1), body: "今日は\n美味しい\nカレーを作った") }

      it '改行をスペースに変換する' do
        result = helper.x_share_text(entry)
        body_part = result.split("\n\n").first
        expect(body_part).not_to include("\n")
        expect(body_part).to include('今日は 美味しい カレーを作った')
      end
    end
  end
end
