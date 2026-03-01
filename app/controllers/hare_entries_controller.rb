class HareEntriesController < ApplicationController
    before_action :authenticate_user!, except: [ :public ]
    before_action :set_hare_entry, only: [ :show, :edit, :update, :destroy ]
    before_action :set_hare_tags, only: [ :new, :create, :edit, :update ]

    def index
      @hare_entries = current_user.hare_entries.with_attached_photo.includes(:hare_tags).order(occurred_on: :desc, created_at: :desc).page(params[:page]).per(20)
      @monthly_points = current_user.monthly_points
      @level = current_user.level
    end

    def show
    end

    def new
      @hare_entry = HareEntry.new(occurred_on: Date.today, body: params[:body])
    end

    def create
      @hare_entry = current_user.hare_entries.build(hare_entry_params)

      if @hare_entry.save
        PointAwardService.call(@hare_entry)
        redirect_to hare_entry_path(@hare_entry), notice: "ハレを記録しました！"
      else
        render :new, status: :unprocessable_entity
      end
    end

    def edit
    end

    def update
      @hare_entry.photo.purge if hare_entry_params[:remove_photo] == "1"

      if @hare_entry.update(hare_entry_params)
        PointRecalculationService.call(@hare_entry)
        redirect_to hare_entry_path(@hare_entry), notice: "ハレの記録を更新しました"
      else
        render :edit, status: :unprocessable_entity
      end
    end

    def destroy
      @hare_entry.destroy
      PointRecalculationService.recalculate_total(current_user)
      redirect_to hare_entries_path, notice: "ハレの記録を削除しました"
    end

    def public
      @hare_entries = HareEntry
        .publicly_visible
        .includes(:user, :hare_tags)
        .with_attached_photo
        .recent
        .page(params[:page])
        .per(25)
    end

    private

    def set_hare_entry
      @hare_entry = current_user.hare_entries.find(params[:id])
    end

    def set_hare_tags
      @hare_tags = HareTag.active.sorted
    end

    def hare_entry_params
      params.require(:hare_entry).permit(:body, :occurred_on, :visibility, :photo, :remove_photo, hare_tag_ids: [])
    end
end
