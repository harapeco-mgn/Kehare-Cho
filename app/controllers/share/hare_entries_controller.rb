module Share
  class HareEntriesController < ApplicationController
    layout "share"

    def show
      @hare_entry = HareEntry.publicly_visible.find_by!(share_token: params[:token])
    rescue ActiveRecord::RecordNotFound
      render file: Rails.public_path.join("404.html"), status: :not_found, layout: false
    end
  end
end
