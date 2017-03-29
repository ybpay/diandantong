module Ddt
  class AccessToken < Base
    validates :access_token, presence: true, uniqueness: true
    belongs_to :holder, polymorphic: true
    belongs_to :account, :class_name => 'Ddt::Account', :foreign_key => :holder_id, :foreign_type => :holder_type

    before_validation do
      self.access_token = generate_authentication_token unless self.access_token.present?
    end

    scope :active, ->{where(active: true)}
    scope :valid, ->{active.where('expired_at > now()')}

    #
    # acquire token for holder
    #
    def self.acquire(holder, ttl = 1.days)
      Ddt::AccessToken.create!(
          holder: holder,
          expired_at: ttl.since,
          active: true
      )
    end

    #
    # fetch AccessToken by token string
    #
    def self.get(token)
      self.active.where('access_token = :token and expired_at > now()',token: token).first
    end

    #
    # drop the token, make it inactive
    #
    def drop
      self.update_column(:active, false)
    end

    def others
      Ddt::AccessToken.where(
          holder: self.holder,
          active: true
      )
      .where.not(id: self.id)
    end

    private
    #
    # 为登陆的用户添加生成 TOKEN，以支付使用 API 时利用 TOKEN 登陆
    #
    def generate_authentication_token
      len = 16
      loop do
        token = SecureRandom.hex(len)
        break token unless AccessToken.where(access_token: token).first
        len += 1
      end
    end
  end
end
