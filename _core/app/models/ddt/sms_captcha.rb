#encoding:utf-8
module Ddt
  class SmsCaptcha < Ddt::Base
    belongs_to :short_message, class_name: 'Ddt::ShortMessage'
    before_create :generate_code
    validate :check_frequency
    validates :phone, presence: true, length: 3..20
    auto_strip_attributes :phone, :delete_whitespaces => true

    def expired?
      self.created_at < 30.minutes.ago
    end

    def correct_code?(code, phone)
      !expired? && !self.validated && self.code == code.to_s && self.phone == phone
    end

    def validate!
      self.update_attribute(:validated, true)
    end

    def self.need_image_captcha?(ip, session_hash)
      # 过去1小时，同一 IP 有1条记录
      Ddt::SmsCaptcha.where("ip = :ip or session_hash = :session_hash", {ip: ip, session_hash: session_hash}).where(created_at: [1.hours.ago..DateTime.now]).count > 5
    end

    def self.to_csv(options = {})
      CSV.generate(options) do |csv|
        csv << FILE_HEADER
        order(:created_at => :desc).each do |it|
          csv << it.row_info
        end
      end
    end

    def row_info
      [
          self.code,
          self.phone,
          self.validated? ? '是' : '否',
          self.updated_at.strftime('%Y-%m-%d %H:%M:%S')
      ]
    end

    def generate_code
      self.code = '%06d' % rand(1000000) if self.code.nil?
    end

    private

    def single_limit
      Time.now < Time.parse('2016-12-25') ? 1000 : 15
    end

    # 对一个手机号每分钟只能发送一条
    def check_frequency
      if Ddt::SmsCaptcha.where(:created_at => [1.day.ago..DateTime.now]).count > 1000
        self.errors.add(:phone, '当天累计发送短信超过额定标准，为防止恶意注册，系统已经暂停短信验证码服务，如有需要，请联系客服')
      end

      if Ddt::SmsCaptcha.where('created_at > ?', 1.minutes.ago).where('phone = ? or ip = ? or session_hash = ?', self.phone, self.ip, self.session_hash).count > 0
        self.errors.add(:phone, '您请求验证码的时间太过频繁，请等待一分钟再进行发送')
      end

      same_phone_captchas_count = Ddt::SmsCaptcha.where(phone: self.phone).where(:created_at => [1.day.ago..DateTime.now]).count
      if same_phone_captchas_count >= 5
        self.errors.add(:phone, '同一手机24小时内最多只能收取5条短信验证码')
      end

      same_ip_captchas_count = Ddt::SmsCaptcha.where(ip: self.ip).where(:created_at => [1.day.ago..DateTime.now]).count
      if same_ip_captchas_count >= single_limit
        self.errors.add(:phone, '对不起，您所使用的网络本日申请验证码次数已经超过限额，请24小时候再次尝试')
      end

      same_session_captchas_count = Ddt::SmsCaptcha.where(session_hash: self.session_hash).where(:created_at => [1.day.ago..DateTime.now]).count
      if same_session_captchas_count >= 10
        self.errors.add(:phone, '同一手机24小时内最多只能收取10条短信验证码')
      end
    end

    FILE_HEADER = %W[
      验证码
      电话号码
      通过检验
      更新时间
    ]

  end
end