require "rails_helper"

RSpec.describe HareEntryStatsService do
  let(:user) { create(:user) }
  let(:service) { described_class.new(user) }

  describe "#entry_count" do
    it "直近30日間の記録件数を返す" do
      create(:hare_entry, user: user, occurred_on: 1.day.ago)
      create(:hare_entry, user: user, occurred_on: 31.days.ago)
      expect(service.entry_count).to eq(1)
    end

    it "他ユーザーの記録は含まない" do
      other_user = create(:user)
      create(:hare_entry, user: other_user, occurred_on: 1.day.ago)
      expect(service.entry_count).to eq(0)
    end
  end

  describe "#recording_rate" do
    it "記録率を0〜100の整数で返す" do
      15.times { create(:hare_entry, user: user, occurred_on: 1.day.ago) }
      expect(service.recording_rate).to eq(50)
    end

    it "記録がない場合は0を返す" do
      expect(service.recording_rate).to eq(0)
    end
  end

  describe "#current_streak" do
    it "今日から連続して記録している日数を返す" do
      create(:hare_entry, user: user, occurred_on: Date.today)
      create(:hare_entry, user: user, occurred_on: 1.day.ago)
      create(:hare_entry, user: user, occurred_on: 2.days.ago)
      expect(service.current_streak).to eq(3)
    end

    it "今日の記録がない場合は0を返す" do
      create(:hare_entry, user: user, occurred_on: 1.day.ago)
      expect(service.current_streak).to eq(0)
    end

    it "途中で途切れた場合は連続日数のみを返す" do
      create(:hare_entry, user: user, occurred_on: Date.today)
      create(:hare_entry, user: user, occurred_on: 3.days.ago)
      expect(service.current_streak).to eq(1)
    end
  end

  describe "#tag_ranking" do
    it "よく使ったタグを件数降順で返す" do
      tag1 = create(:hare_tag, label: "和食")
      tag2 = create(:hare_tag, label: "簡単")
      3.times do
        entry = create(:hare_entry, user: user, occurred_on: 1.day.ago)
        create(:hare_entry_tag, hare_entry: entry, hare_tag: tag1)
      end
      2.times do
        entry = create(:hare_entry, user: user, occurred_on: 1.day.ago)
        create(:hare_entry_tag, hare_entry: entry, hare_tag: tag2)
      end
      ranking = service.tag_ranking
      expect(ranking.first).to eq([ "和食", 3 ])
      expect(ranking.to_a.second).to eq([ "簡単", 2 ])
    end

    it "直近30日外の記録のタグは含まない" do
      tag = create(:hare_tag, label: "和食")
      entry = create(:hare_entry, user: user, occurred_on: 31.days.ago)
      create(:hare_entry_tag, hare_entry: entry, hare_tag: tag)
      expect(service.tag_ranking).to be_empty
    end
  end

  describe "#total_points" do
    it "直近30日間の累計ポイントを返す" do
      create(:hare_entry, user: user, occurred_on: 1.day.ago, awarded_points: 10)
      create(:hare_entry, user: user, occurred_on: 1.day.ago, awarded_points: 20)
      expect(service.total_points).to eq(30)
    end

    it "30日より前のポイントは含まない" do
      create(:hare_entry, user: user, occurred_on: 31.days.ago, awarded_points: 100)
      expect(service.total_points).to eq(0)
    end
  end

  describe "#average_points" do
    it "記録がない場合は0を返す" do
      expect(service.average_points).to eq(0)
    end

    it "平均ポイントを整数で返す" do
      create(:hare_entry, user: user, occurred_on: 1.day.ago, awarded_points: 10)
      create(:hare_entry, user: user, occurred_on: 1.day.ago, awarded_points: 21)
      expect(service.average_points).to eq(16)
    end
  end

  describe "#enough_data?" do
    it "30件未満の場合はfalseを返す" do
      29.times { create(:hare_entry, user: user, occurred_on: 1.day.ago) }
      expect(service.enough_data?).to be false
    end

    it "30件以上の場合はtrueを返す" do
      30.times { create(:hare_entry, user: user, occurred_on: 1.day.ago) }
      expect(service.enough_data?).to be true
    end
  end
end
