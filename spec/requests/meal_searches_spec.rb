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

      it "cook_contextの選択肢が表示される" do
        get new_meal_search_path
        expect(response.body).to include("自炊")
        expect(response.body).to include("外食")
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

      it "meal_searches_path にリダイレクトする" do
        post meal_searches_path, params: { genre_id: genre.id }
        expect(response).to redirect_to(meal_searches_path)
      end

      it "候補IDをセッションに保存する" do
        post meal_searches_path, params: { genre_id: genre.id }
        expect(session[:meal_candidates]).to be_present
        expect(session[:meal_candidates].size).to eq(3)
      end

      it "検索ログ（MealSearch）が作成される" do
        expect {
          post meal_searches_path, params: { genre_id: genre.id }
        }.to change(MealSearch, :count).by(1)
      end

      it "検索ログが current_user に紐づく" do
        post meal_searches_path, params: { genre_id: genre.id }
        meal_search = MealSearch.last
        expect(meal_search.user).to eq(user)
      end

      it "検索ログに genre_id が保存される" do
        post meal_searches_path, params: { genre_id: genre.id }
        meal_search = MealSearch.last
        expect(meal_search.genre_id).to eq(genre.id)
      end

      it "検索ログに presented_candidate_names が配列で保存される" do
        post meal_searches_path, params: { genre_id: genre.id }
        meal_search = MealSearch.last
        expect(meal_search.presented_candidate_names).to be_an(Array)
        expect(meal_search.presented_candidate_names.size).to eq(3)
      end

      it "検索ログの presented_candidate_names が候補の name を含む" do
        post meal_searches_path, params: { genre_id: genre.id }
        meal_search = MealSearch.last
        candidates = MealCandidate.where(id: session[:meal_candidates])

        candidates.each do |candidate|
          expect(meal_search.presented_candidate_names).to include(candidate.name)
        end
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

        it "他ジャンルから補完して3件の候補IDをセッションに保存する" do
          post meal_searches_path, params: { genre_id: genre.id }
          expect(session[:meal_candidates]).to be_present
          expect(session[:meal_candidates].size).to eq(3)
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

  describe "GET /meal_searches" do
    let(:genre) { create(:genre) }

    context "ログイン済みユーザーの場合" do
      before { sign_in user }

      context "POST でセッションに候補を保存した後" do
        let!(:candidates) { create_list(:meal_candidate, 3, genre: genre, is_active: true) }

        before do
          # POST で候補を選択してセッションに保存
          post meal_searches_path, params: { genre_id: genre.id }
          # GET で候補一覧を表示
          get meal_searches_path
        end

        it "200が返る" do
          expect(response).to have_http_status(:ok)
        end

        it "@candidates に候補を設定する" do
          expect(assigns(:candidates)).to be_present
          expect(assigns(:candidates).size).to eq(3)
        end

        it "@genres と @moods を設定する" do
          expect(assigns(:genres)).to eq(Genre.all)
          expect(assigns(:moods)).to eq(MoodTag.all)
        end

        it "候補の料理名が表示される" do
          get meal_searches_path
          candidates = assigns(:candidates)
          candidates.each do |candidate|
            expect(response.body).to include(candidate.name)
          end
        end

        it "各候補にGoogle検索リンクが含まれる" do
          get meal_searches_path
          expect(response.body).to include("Google で検索")
        end

        it "Google検索リンクのURLが正しい" do
          get meal_searches_path
          candidates = assigns(:candidates)
          candidates.each do |candidate|
            expected_url = GoogleSearchQueryBuilder.new(candidate.name).url
            expect(response.body).to include(expected_url)
          end
        end
      end

      context "セッションに候補が保存されていない場合" do
        before do
          get meal_searches_path
        end

        it "200が返る" do
          expect(response).to have_http_status(:ok)
        end

        it "@candidates は空" do
          expect(assigns(:candidates)).to be_nil
        end
      end

      context "ログ一覧の表示（Issue #40）" do
        let(:other_user) { create(:user) }
        let!(:my_log1) { create(:meal_search, user: user, genre: genre, created_at: 2.days.ago) }
        let!(:my_log2) { create(:meal_search, user: user, genre: genre, created_at: 1.day.ago) }
        let!(:other_log) { create(:meal_search, user: other_user, genre: genre, created_at: 1.hour.ago) }

        before do
          get meal_searches_path
        end

        it "200が返る" do
          expect(response).to have_http_status(:ok)
        end

        it "@meal_searches に自分のログを設定する" do
          expect(assigns(:meal_searches)).to be_present
          expect(assigns(:meal_searches).size).to eq(2)
        end

        it "自分のログのみが表示される（他ユーザーのログは表示されない）" do
          expect(assigns(:meal_searches)).to include(my_log1, my_log2)
          expect(assigns(:meal_searches)).not_to include(other_log)
        end

        it "新しい順に並んでいる" do
          meal_searches = assigns(:meal_searches)
          expect(meal_searches.first).to eq(my_log2)  # 1日前が最初
          expect(meal_searches.last).to eq(my_log1)   # 2日前が最後
        end

        it "/home への導線が存在する" do
          expect(response.body).to include('href="/home"')
        end
      end

      context "ログが0件の場合" do
        before do
          user.meal_searches.destroy_all
          get meal_searches_path
        end

        it "200が返る" do
          expect(response).to have_http_status(:ok)
        end

        it "@meal_searches が空" do
          expect(assigns(:meal_searches)).to be_empty
        end

        it "空状態のメッセージが表示される" do
          expect(response.body).to include("まだ献立相談のログがありません")
        end
      end
    end

    context "未ログインユーザーの場合" do
      it "/users/sign_inにリダイレクトされる" do
        get meal_searches_path
        expect(response).to redirect_to(new_user_session_path)
      end
    end
  end

  describe "POST /meal_searches (外食選択時)" do
    let(:genre) { Genre.find_or_create_by(key: "japanese") { |g| g.label = "和食" } }
    let(:mood) { MoodTag.find_or_create_by(key: "energetic") { |m| m.label = "がっつり食べたい" } }

    context "ログイン済みユーザーの場合" do
      before { sign_in user }

      context "外食を選択した場合" do
        it "Google Mapsにリダイレクトする" do
          post meal_searches_path, params: {
            cook_context: "eat_out",
            genre_id: genre.id
          }

          expect(response).to have_http_status(:redirect)
          expect(response.location).to include("google.com/maps/search/")
        end

        it "リダイレクト先のURLにapi=1パラメータが含まれる" do
          post meal_searches_path, params: {
            cook_context: "eat_out",
            genre_id: genre.id
          }

          expect(response.location).to include("api=1")
        end

        it "リダイレクト先のURLにジャンル名が含まれる" do
          post meal_searches_path, params: {
            cook_context: "eat_out",
            genre_id: genre.id
          }

          expect(response.location).to include(CGI.escape("和食"))
        end

        it "リダイレクト先のURLに「惣菜」が含まれる" do
          post meal_searches_path, params: {
            cook_context: "eat_out",
            genre_id: genre.id
          }

          expect(response.location).to include(CGI.escape("惣菜"))
        end

        it "リダイレクト先のURLに「定食」が含まれる" do
          post meal_searches_path, params: {
            cook_context: "eat_out",
            genre_id: genre.id
          }

          expect(response.location).to include(CGI.escape("定食"))
        end

        it "検索ログ（MealSearch）が作成される" do
          expect {
            post meal_searches_path, params: {
              cook_context: "eat_out",
              genre_id: genre.id
            }
          }.to change(MealSearch, :count).by(1)
        end

        it "検索ログのcook_contextが「eat_out」になる" do
          post meal_searches_path, params: {
            cook_context: "eat_out",
            genre_id: genre.id
          }

          meal_search = MealSearch.last
          expect(meal_search.cook_context).to eq("eat_out")
        end

        it "検索ログのpresented_candidate_namesが空配列になる" do
          post meal_searches_path, params: {
            cook_context: "eat_out",
            genre_id: genre.id
          }

          meal_search = MealSearch.last
          expect(meal_search.presented_candidate_names).to eq([])
        end

        it "セッションに候補IDが保存されない" do
          post meal_searches_path, params: {
            cook_context: "eat_out",
            genre_id: genre.id
          }

          expect(session[:meal_candidates]).to be_nil
        end

        context "気分タグも指定した場合" do
          it "リダイレクト先のURLに気分タグのキーワードが含まれる" do
            post meal_searches_path, params: {
              cook_context: "eat_out",
              genre_id: genre.id,
              mood_tag_id: mood.id
            }

            expect(response.location).to include(CGI.escape("ボリューム"))
          end
        end
      end
    end

    context "未ログインユーザーの場合" do
      it "/users/sign_inにリダイレクトされる" do
        post meal_searches_path, params: {
          cook_context: "eat_out",
          genre_id: genre.id
        }

        expect(response).to redirect_to(new_user_session_path)
      end
    end
  end
end
