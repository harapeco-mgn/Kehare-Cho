class HareEntriesController < ApplicationController
  before_action :authenticate_user!

  def new
    @hare_entry = HareEntry.new
  end

  def create
    @hare_entry = current_user.hare_entries.build(hare_entry_params)

    if @hare_entry.save
      redirect_to root_path, notice: "ハレの記録を作成しました"
    else
      render :new, status: :unprocessable_entity
    end
  end

  private

  def hare_entry_params
    params.require(:hare_entry).permit(:body, :occurred_on, :visibility)
  end
end
