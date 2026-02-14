# frozen_string_literal: true

class Users::RegistrationsController < Devise::RegistrationsController
  def create
    super do |resource|
      if resource.errors[:email].any? { |msg| msg == I18n.t("errors.messages.taken") }
        resource.errors.delete(:email)
        resource.errors.add(:base, I18n.t("devise.registrations.generic_error"))
      end
    end
  end
end
