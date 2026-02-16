class HareEntriesController < ApplicationController
    before_action :authenticate_user!
    before_action :set_hare_entry, only: [ :show, :edit, :update, :destroy ]

    def index
      @hare_entries = current_user.hare_entries.with_attached_photo.order(created_at: :desc)
      @monthly_points = current_user.monthly_points
      @level = current_user.level
    end

    def show
    end

    def new
      @hare_entry = HareEntry.new(occurred_on: Date.today)
      @hare_tags = HareTag.active.sorted
    end

    def create
      @hare_entry = current_user.hare_entries.build(hare_entry_params)

      if @hare_entry.save
        PointAwardService.call(@hare_entry)
        redirect_to hare_entry_path(@hare_entry), notice: "ハレを記録しました！"
      else
        @hare_tags = HareTag.active.sorted
        render :new, status: :unprocessable_entity
      end
    end

    def edit
      @hare_tags = HareTag.active.sorted
    end

    def update
      @hare_entry.photo.purge if @hare_entry.remove_photo == "1"

      if @hare_entry.update(hare_entry_params)
        PointRecalculationService.call(@hare_entry)
        redirect_to hare_entry_path(@hare_entry), notice: "ハレの記録を更新しました"
      else
        @hare_tags = HareTag.active.sorted
        render :edit, status: :unprocessable_entity
      end
    end

    def destroy
      @hare_entry.destroy
      redirect_to hare_entries_path, notice: "ハレの記録を削除しました"
    end

    private

    def set_hare_entry
      @hare_entry = current_user.hare_entries.find(params[:id])
    end

    def hare_entry_params
      params.require(:hare_entry).permit(:body, :occurred_on, :visibility, :photo, :remove_photo, hare_tag_ids: [])
    end
end
