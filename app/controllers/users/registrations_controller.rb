# frozen_string_literal: true

module Users
  class RegistrationsController < Devise::RegistrationsController
    # POST /resource
    def create
      super do |resource|
        # メールアドレス重複エラーを汎用的なメッセージに置換（ユーザー列挙攻撃対策）
        if resource.errors[:email].include?(I18n.t("errors.messages.taken"))
          resource.errors.delete(:email)
          resource.errors.add(:base, I18n.t("devise.failure.email_unavailable"))
        end
      end
    end

    def after_sign_up_path_for(resource)
      how_to_use_path
    end
  end
end
