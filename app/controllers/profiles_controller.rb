class ProfilesController < ApplicationController
  before_action :authenticate_user!  # Devise の認証チェック
  before_action :set_user

  def show
    @total_points            = @user.point_transactions.sum(:points)
    @total_hare_entries_count = @user.hare_entries.count
  end

  def edit
  end

  def update
    if @user.update(profile_params)
      redirect_to profile_path, notice: "プロフィールを更新しました"
    else
      render :edit, status: :unprocessable_entity
    end
  end

  private

  def set_user
    @user = current_user
  end

  def profile_params
    params.require(:user).permit(:nickname)
  end
end
