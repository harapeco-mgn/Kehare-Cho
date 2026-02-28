require "rails_helper"

RSpec.describe "MealGuide", type: :request do
  describe "GET /meal_guide" do
    context "未ログイン時" do
      it "200 を返す" do
        get meal_guide_path
        expect(response).to have_http_status(:ok)
      end

      it "選択ページのコンテンツが含まれる" do
        get meal_guide_path
        expect(response.body).to include("かんたん献立")
        expect(response.body).to include("AI献立相談")
      end
    end

    context "ログイン時" do
      let(:user) { create(:user) }

      before { sign_in user }

      it "200 を返す" do
        get meal_guide_path
        expect(response).to have_http_status(:ok)
      end
    end
  end
end
