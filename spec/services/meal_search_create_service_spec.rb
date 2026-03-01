require "rails_helper"

RSpec.describe MealSearchCreateService do
  let(:user) { create(:user) }
  let(:genre) { create(:genre) }

  describe ".call" do
    context "自炊（self_cook）の場合" do
      let(:params) do
        ActionController::Parameters.new(
          genre_id: genre.id,
          cook_context: "self_cook",
          required_minutes: 20,
          mood_tag_id: nil
        )
      end

      before do
        create_list(:meal_candidate, 5, genre: genre, is_active: true)
      end

      it "MealSearch レコードを作成する" do
        expect { described_class.call(user: user, params: params) }.to change(MealSearch, :count).by(1)
      end

      it "cook_context が self_cook で保存される" do
        described_class.call(user: user, params: params)
        expect(MealSearch.last.cook_context).to eq("self_cook")
      end

      it "candidate_ids を返す" do
        result = described_class.call(user: user, params: params)
        expect(result.candidate_ids).to be_an(Array)
        expect(result.candidate_ids).not_to be_empty
      end

      it "eat_out が false である" do
        result = described_class.call(user: user, params: params)
        expect(result.eat_out).to be false
      end

      it "token が nil である" do
        result = described_class.call(user: user, params: params)
        expect(result.token).to be_nil
      end
    end

    context "外食（eat_out）の場合" do
      let(:genre) { Genre.find_or_create_by(key: "japanese") { |g| g.label = "和食" } }
      let(:params) do
        ActionController::Parameters.new(
          genre_id: genre.id,
          cook_context: "eat_out",
          mood_tag_id: nil
        )
      end

      it "MealSearch レコードを作成する" do
        expect { described_class.call(user: user, params: params) }.to change(MealSearch, :count).by(1)
      end

      it "cook_context が eat_out で保存される" do
        described_class.call(user: user, params: params)
        expect(MealSearch.last.cook_context).to eq("eat_out")
      end

      it "presented_candidate_names が空配列で保存される" do
        described_class.call(user: user, params: params)
        expect(MealSearch.last.presented_candidate_names).to eq([])
      end

      it "eat_out が true である" do
        result = described_class.call(user: user, params: params)
        expect(result.eat_out).to be true
      end

      it "token を返す" do
        result = described_class.call(user: user, params: params)
        expect(result.token).to be_present
      end

      it "session_payload に Maps URL が含まれる" do
        result = described_class.call(user: user, params: params)
        expect(result.session_payload["url"]).to include("google.com/maps/search/")
      end

      it "session_payload に genre_label が含まれる" do
        result = described_class.call(user: user, params: params)
        expect(result.session_payload["genre_label"]).to eq("和食")
      end

      it "candidate_ids が nil である" do
        result = described_class.call(user: user, params: params)
        expect(result.candidate_ids).to be_nil
      end
    end
  end
end
