class BaseAttachmentMailer < ActionMailer::Base
  def notify(to, subject, body, filename, content)
    attachments[filename] = content
    mail(to: to, subject: subject, body: body).deliver
  end
end
