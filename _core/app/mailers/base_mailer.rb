class BaseMailer < ActionMailer::Base
  def notify(to, subject, body)
    mail(to: to, subject: subject, body: body).deliver
  end
end
