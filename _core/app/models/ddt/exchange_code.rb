# encoding:utf-8
require 'bcrypt'
require 'rqrcode_png'
require 'barby'
require 'barby/barcode/code_128'
require 'barby/outputter/html_outputter'
module Ddt
  class ExchangeCode < Ddt::Base
    include Ddt::Scanable
    include AASM

    belongs_to :shop, class_name: 'Ddt::Shop'
    belongs_to :branch, -> { with_discarded }, class_name: 'Ddt::Branch'
    validates_presence_of :shop

    skip_callback :create, :after, :create_qr_code
    # exchangeable: ReservationOrder, BaseCoupon(Coupon, Groupon, Voucher)
    belongs_to :exchangeable, polymorphic: true


    # validation
    validates_uniqueness_of :code, scope: :shop_id
    validates_presence_of :code

    #  callback
    set_from :exchangeable
    before_validation :set_code
    record_state_change_for :state

    def exchangeable
      if self.exchangeable_type == "Ddt::Order"
        @exchangeable ||= OrderService::Order::Base.find(self.exchangeable_id)
      else
        super
      end
    end

    acts_as_type :state, [:pending, :exchanged, :canceled],%W[可兑换 已兑换 已取消]
    aasm column: :state do
      state :pending, :exchanged, :canceled, initial: :pending

      event :exchange do
        transitions from: :pending, to: :exchanged
      end
      event :cancel do
        transitions from: :pending, to: :canceled
      end
      after_transition from: :pending, to: :exchanged, do: :after_exchange
      after_transition from: :pending, to: :canceled, do: :after_cancel
    end

    def after_exchange
      self.touch(:exchanged_at)
      if self.exchangeable.user.present?
        self.shop.notify_to(self.exchangeable.user, {
          title: "您的兑换码#{self.code}已兑换成功",
          description: self.exchangeable.exchange_detail_decode,
          url: exchange_success_url
        })
      end
      self.exchangeable.after_exchange
    end

    def after_cancel
      # TODO
    end

    def self.random_code(length)
      array = [('0'..'9')].map(&:to_a).flatten
      (0...length).map { array[rand(array.length)] }.join
    end

    def get_qr_code
      if self.qr_code_scene.present?
        if self.is_qr_code_expired?
          self.qr_code_scene.destroy
          self.create_qr_code
          self.qr_code_scene
        else
          self.qr_code_scene
        end
      else
        self.create_qr_code
      end
    end

    def is_qr_code_expired?
      self.qr_code_scene.created_at < 10.minutes.ago
    end

    # 当用户扫码后目标对象为该model时，系统自动跳转的路由地址
    def weixin_path
      "?_ng_path=/exchange_codes/#{self.id}"
    end

    def name
      self.exchangeable.try(:number) || self.exchangeable.id
    end

    def allow_scan?(user=nil)
      if !is_qr_code_expired?
        true
      else
        self.errors.add(:base, '该二维码已过期，请重新获取进行扫码')
        false
      end
    end

    def exchange_success_url
      exchangeable_id = self.exchangeable.id
      path = \
        case self.exchangeable.class.name.demodulize.downcase.to_sym
        when :coupon  then "/user/coupons/#{exchangeable_id}"
        when :groupon then "/user/groupons/#{exchangeable_id}"
        when :voucher then "/user/vouchers/#{exchangeable_id}"
        when :reservationorder then "/orders/reservation/#{exchangeable_id}"
        end
      URI.join(Rails.application.routes.url_helpers.ddt_url, "weixin/shops/#{self.shop.id}?_ng_path=#{path}" ).to_s
    end

    def code_html
      {
        qrcode: RQRCode::QRCode.new(self.code, :size => 4, :level => :l ).as_html, # 二维码
        barcode: Barby::Code128C.new(self.code).to_html  # 条形码
      }
    end

    def can_exchange_by?(account)
      if account.is_boss?
        true
      else
        branch_ids = account.manage_branch_ids
        if self.branch_id.present?
          branch_ids.include?(self.branch_id)
        else
          # coupon
          coupon = self.exchangeable
          if coupon.abstract_coupon_version.is_appliable_to_part_branch?
            (coupon.abstract_coupon_version.branch_ids & branch_ids).present?
          else
            true
          end
        end
      end
    end

    private
    def set_code
      if self.code.blank?
        self.code = loop do
          code = Ddt::ExchangeCode.random_code(10)
          if !self.shop.exchange_codes.exists?(code: code)
            break code
          end
        end
      end
    end


  end
end
