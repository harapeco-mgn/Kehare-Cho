class ReflectionsController < ApplicationController
  before_action :authenticate_user!

  def show
    @stats = HareEntryStatsService.new(current_user)
  end
end
