# frozen_string_literal: true

module ApplicationCable
  # WebSocket 接続の認証を管理する
  # Devise の Warden セッションを使って current_user を識別する
  class Connection < ActionCable::Connection::Base
    identified_by :current_user

    def connect
      self.current_user = find_verified_user
    end

    private

    def find_verified_user
      verified_user = env["warden"].user
      reject_unauthorized_connection unless verified_user
      verified_user
    end
  end
end
