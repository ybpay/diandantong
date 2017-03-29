class StatisticMailer < ActionMailer::Base
  def notify(to, subject, body)
    mail(to: to, subject: subject, body: body, cc: Rails.application.config.supervisor_mail)
  end
end
