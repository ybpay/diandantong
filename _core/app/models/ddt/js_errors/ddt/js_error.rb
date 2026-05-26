#encoding: utf-8
module Ddt
  class JsError < Ddt::DdtEx
    has_many :js_error_counts, class_name: 'Ddt::JsErrorCount'
    DIGEST_ATTRIBUTES = [:url, :agent, :error_message, :stack_trace, :cause]

    validates_presence_of :url


    before_validation :generate_digest do
      generate_digest unless self.digest.present?
    end

    # after_create :send_mail
    # after_update :send_mail

    def generate_digest
      string = DIGEST_ATTRIBUTES.reduce(''){|sum,attr|sum + self.send(attr).to_s}
      self.digest = Digest::SHA1.hexdigest(string)
    end

    def same?(other)
      DIGEST_ATTRIBUTES.all? do |attribute|
        self.send(attribute) ==  other.send(attribute)
      end
    end

    private
    @@last = nil
    def send_mail
      # format error
      subject = "[点单通jserror汇报]#{self.error_message[0...100]}"
      body = <<TEXT
URL: #{self.url}

AGENT: #{self.agent}

COUNT: #{self.count}

ERROR_MESSAGE: #{self.error_message}

CAUSE: #{self.cause}

STACK_TRACE:

#{self.stack_trace}
TEXT
      # 一分钟只发一条
      if !@@last.present? || @@last < 1.minutes.ago
        @@last = Time.now
        BaseMailer.notify(Rails.application.config.dev_mail_group, subject, body)
      end
    end

  end
end