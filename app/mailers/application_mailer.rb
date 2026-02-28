class ApplicationMailer < ActionMailer::Base
  default from: ENV.fetch("MAIL_FROM", "noreply@kehare-cho.com")
  layout "mailer"
end
