require 'rails_helper'

RSpec.describe "MealSearches", type: :request do
  let(:user) { create(:user) }

  describe "GET /meal_searches/new" do
    context "ログイン済みユーザーの場合" do
      before { sign_in user }

      it "200が返る" do
        get new_meal_search_path
        expect(response).to have_http_status(:ok)
      end

      it "ジャンルの選択肢が表示される" do
        # seedデータからジャンルを作成
        genre1 = Genre.find_or_create_by(key: "japanese") { |g| g.label = "和食" }
        genre2 = Genre.find_or_create_by(key: "western") { |g| g.label = "洋食" }

        get new_meal_search_path
        expect(response.body).to include(genre1.label)
        expect(response.body).to include(genre2.label)
      end

      it "気分タグの選択肢が表示される" do
        # seedデータから気分タグを作成
        mood1 = MoodTag.find_or_create_by(key: "energetic") { |m| m.label = "元気を出したい" }
        mood2 = MoodTag.find_or_create_by(key: "relaxed") { |m| m.label = "リラックスしたい" }

        get new_meal_search_path
        expect(response.body).to include(mood1.label)
        expect(response.body).to include(mood2.label)
      end

      it "meal_modeの選択肢が表示される" do
        get new_meal_search_path
        expect(response.body).to include("自炊")
        expect(response.body).to include("中食")
      end

      it "cook_contextの選択肢が表示される" do
        get new_meal_search_path
        expect(response.body).to include("買い物")
        expect(response.body).to include("家にある")
      end

      it "required_minutesの選択肢が表示される" do
        get new_meal_search_path
        expect(response.body).to include("10")
        expect(response.body).to include("20")
        expect(response.body).to include("30")
      end
    end

    context "未ログインユーザーの場合" do
      it "/users/sign_inにリダイレクトされる" do
        get new_meal_search_path
        expect(response).to redirect_to(new_user_session_path)
      end
    end
  end

  describe "POST /meal_searches" do
    let(:genre) { create(:genre) }

    context "ログイン済みユーザーの場合" do
      before do
        sign_in user
        # テスト用の候補を作成
        create_list(:meal_candidate, 5, genre: genre, is_active: true)
      end

      it "200が返る" do
        post meal_searches_path, params: { genre_id: genre.id }
        expect(response).to have_http_status(:ok)
      end

      it "new テンプレートをレンダリングする" do
        post meal_searches_path, params: { genre_id: genre.id }
        expect(response).to render_template(:new)
      end

      it "@candidates に3件の候補を設定する" do
        post meal_searches_path, params: { genre_id: genre.id }
        expect(assigns(:candidates)).to be_present
        expect(assigns(:candidates).size).to eq(3)
      end

      it "@genres と @moods を設定する" do
        post meal_searches_path, params: { genre_id: genre.id }
        expect(assigns(:genres)).to eq(Genre.all)
        expect(assigns(:moods)).to eq(MoodTag.all)
      end

      context "ジャンル一致候補が3件未満の場合" do
        let(:other_genre) { create(:genre, key: 'other', label: 'その他') }

        before do
          # 既存の候補をクリア
          MealCandidate.destroy_all
          # ジャンル一致を2件、他ジャンルを3件作成
          create_list(:meal_candidate, 2, genre: genre, is_active: true)
          create_list(:meal_candidate, 3, genre: other_genre, is_active: true)
        end

        it "他ジャンルから補完して3件の候補を返す" do
          post meal_searches_path, params: { genre_id: genre.id }
          candidates = assigns(:candidates)
          expect(candidates.size).to eq(3)
          # ジャンル一致の2件が含まれることを確認
          expect(candidates.count { |c| c.genre_id == genre.id }).to eq(2)
        end
      end
    end

    context "未ログインユーザーの場合" do
      it "/users/sign_inにリダイレクトされる" do
        post meal_searches_path, params: { genre_id: genre.id }
        expect(response).to redirect_to(new_user_session_path)
      end
    end
  end
end
