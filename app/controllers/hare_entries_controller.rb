class HareEntriesController < ApplicationController
    before_action :authenticate_user!
    before_action :set_hare_entry, only: [ :show, :edit, :update ]

    def index
      @hare_entries = current_user.hare_entries.order(created_at: :desc)
    end

    def show
    end

    def new
      @hare_entry = HareEntry.new
    end

    def create
      @hare_entry = current_user.hare_entries.build(hare_entry_params)

      if @hare_entry.save
        redirect_to hare_entry_path(@hare_entry), notice: "ハレの記録を作成しました"
      else
        render :new, status: :unprocessable_entity
      end
    end

    def edit
    end

    def update
      if @hare_entry.update(hare_entry_params)
        redirect_to hare_entry_path(@hare_entry), notice: "ハレの記録を更新しました"
      else
        render :edit, status: :unprocessable_entity
      end
    end

    private

    def set_hare_entry
      @hare_entry = current_user.hare_entries.find(params[:id])
    end

    def hare_entry_params
      params.require(:hare_entry).permit(:body, :occurred_on, :visibility)
    end
end
