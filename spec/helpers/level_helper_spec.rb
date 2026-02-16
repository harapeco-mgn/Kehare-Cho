# frozen_string_literal: true

require 'rails_helper'

RSpec.describe LevelHelper, type: :helper do
  describe '#level_image_url' do
    context 'レベル0の場合' do
      it '芽生えのイラストURLを返す' do
        url = helper.level_image_url(0)
        expect(url).to include('kehare-cho/levels/beginner')
        expect(url).to include('cloudinary.com')
      end
    end

    context 'レベル1-3の場合' do
      it '日々のイラストURLを返す' do
        url = helper.level_image_url(2)
        expect(url).to include('kehare-cho/levels/apprentice')
        expect(url).to include('cloudinary.com')
      end
    end

    context 'レベル4-6の場合' do
      it '彩りのイラストURLを返す' do
        url = helper.level_image_url(5)
        expect(url).to include('kehare-cho/levels/intermediate')
        expect(url).to include('cloudinary.com')
      end
    end

    context 'レベル7-9の場合' do
      it '華やぎのイラストURLを返す' do
        url = helper.level_image_url(8)
        expect(url).to include('kehare-cho/levels/advanced')
        expect(url).to include('cloudinary.com')
      end
    end

    context 'レベル10以上の場合' do
      it '豊穣のイラストURLを返す' do
        url = helper.level_image_url(15)
        expect(url).to include('kehare-cho/levels/master')
        expect(url).to include('cloudinary.com')
      end
    end

    context '画像変換オプション' do
      it '256x256のサイズ指定が含まれる' do
        url = helper.level_image_url(0)
        expect(url).to include('w_256')
        expect(url).to include('h_256')
      end

      it 'crop: fill 指定が含まれる' do
        url = helper.level_image_url(0)
        expect(url).to include('c_fill')
      end

      it '品質とフォーマットの自動最適化が含まれる' do
        url = helper.level_image_url(0)
        expect(url).to include('q_auto')
        expect(url).to include('f_auto')
      end
    end
  end

  describe '#level_name' do
    context 'レベル0の場合' do
      it '「芽生え」を返す' do
        expect(helper.level_name(0)).to eq('芽生え')
      end
    end

    context 'レベル1-3の場合' do
      it '「日々」を返す' do
        expect(helper.level_name(1)).to eq('日々')
        expect(helper.level_name(2)).to eq('日々')
        expect(helper.level_name(3)).to eq('日々')
      end
    end

    context 'レベル4-6の場合' do
      it '「彩り」を返す' do
        expect(helper.level_name(4)).to eq('彩り')
        expect(helper.level_name(5)).to eq('彩り')
        expect(helper.level_name(6)).to eq('彩り')
      end
    end

    context 'レベル7-9の場合' do
      it '「華やぎ」を返す' do
        expect(helper.level_name(7)).to eq('華やぎ')
        expect(helper.level_name(8)).to eq('華やぎ')
        expect(helper.level_name(9)).to eq('華やぎ')
      end
    end

    context 'レベル10以上の場合' do
      it '「豊穣」を返す' do
        expect(helper.level_name(10)).to eq('豊穣')
        expect(helper.level_name(15)).to eq('豊穣')
        expect(helper.level_name(100)).to eq('豊穣')
      end
    end
  end
end
