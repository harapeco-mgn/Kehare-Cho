require "rails_helper"

RSpec.describe MealCandidatePicker, type: :service do
  let(:genre) { create(:genre, key: "japanese", label: "和食") }
  let(:other_genre) { create(:genre, key: "western", label: "洋食") }

  describe "#pick" do
    context "genre 一致の候補が3件以上ある場合" do
      let!(:japanese_candidates) do
        5.times.map do |i|
          create(:meal_candidate, genre: genre, name: "和食候補#{i + 1}")
        end
      end

      it "genre 一致から3件を選出する" do
        random = Random.new(42)
        picker = MealCandidatePicker.new(genre_id: genre.id, random: random)
        result = picker.pick(count: 3)

        expect(result.size).to eq(3)
        expect(result.all? { |c| c.genre_id == genre.id }).to be true
      end

      it "重複がない" do
        random = Random.new(42)
        picker = MealCandidatePicker.new(genre_id: genre.id, random: random)
        result = picker.pick(count: 3)

        expect(result.uniq.size).to eq(3)
      end

      it "count パラメータで件数を指定できる" do
        random = Random.new(42)
        picker = MealCandidatePicker.new(genre_id: genre.id, random: random)
        result = picker.pick(count: 2)

        expect(result.size).to eq(2)
      end
    end

    context "genre 一致の候補が3件未満の場合" do
      let!(:japanese_candidates) do
        2.times.map do |i|
          create(:meal_candidate, genre: genre, name: "和食候補#{i + 1}")
        end
      end

      let!(:western_candidates) do
        3.times.map do |i|
          create(:meal_candidate, genre: other_genre, name: "洋食候補#{i + 1}")
        end
      end

      it "genre 一致の候補を全て含む" do
        random = Random.new(42)
        picker = MealCandidatePicker.new(genre_id: genre.id, random: random)
        result = picker.pick(count: 3)

        japanese_ids = japanese_candidates.map(&:id)
        expect(result.select { |c| japanese_ids.include?(c.id) }.size).to eq(2)
      end

      it "不足分を他の候補から補完して3件にする" do
        random = Random.new(42)
        picker = MealCandidatePicker.new(genre_id: genre.id, random: random)
        result = picker.pick(count: 3)

        expect(result.size).to eq(3)
      end

      it "補完された候補は genre 一致とは異なる" do
        random = Random.new(42)
        picker = MealCandidatePicker.new(genre_id: genre.id, random: random)
        result = picker.pick(count: 3)

        supplemented = result.reject { |c| c.genre_id == genre.id }
        expect(supplemented.size).to eq(1)
        expect(supplemented.all? { |c| c.genre_id == other_genre.id }).to be true
      end
    end

    context "候補が全体で3件未満の場合" do
      let!(:candidates) do
        2.times.map do |i|
          create(:meal_candidate, genre: genre, name: "候補#{i + 1}")
        end
      end

      it "存在する候補のみ返す" do
        random = Random.new(42)
        picker = MealCandidatePicker.new(genre_id: genre.id, random: random)
        result = picker.pick(count: 3)

        expect(result.size).to eq(2)
      end
    end

    context "is_active が false の候補を除外する" do
      let!(:active_candidates) do
        3.times.map do |i|
          create(:meal_candidate, genre: genre, name: "有効候補#{i + 1}", is_active: true)
        end
      end

      let!(:inactive_candidates) do
        2.times.map do |i|
          create(:meal_candidate, genre: genre, name: "無効候補#{i + 1}", is_active: false)
        end
      end

      it "is_active が true の候補のみ選出する" do
        random = Random.new(42)
        picker = MealCandidatePicker.new(genre_id: genre.id, random: random)
        result = picker.pick(count: 3)

        expect(result.all?(&:is_active)).to be true
        expect(result.size).to eq(3)
      end
    end

    context "genre_id が nil の場合" do
      let!(:candidates) do
        5.times.map do |i|
          create(:meal_candidate, genre: genre, name: "候補#{i + 1}")
        end
      end

      it "全候補からランダムに選出する" do
        random = Random.new(42)
        picker = MealCandidatePicker.new(genre_id: nil, random: random)
        result = picker.pick(count: 3)

        expect(result.size).to eq(3)
      end
    end
  end
end
