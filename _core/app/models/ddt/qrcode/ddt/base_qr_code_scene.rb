module Ddt
  class BaseQrCodeScene < Ddt::Base
    include Discard::Model
    default_scope { kept }
    ### plugins
    extend FriendlyId
    friendly_id :slug, use: [:slugged, :finders]

    include BelongsToShop
    belongs_to :owner, polymorphic: true
    has_many :qrcode_scan_relations, dependent: :destroy, class_name: "Ddt::QrcodeScanRelation"
    scope :of_builtin, ->{where(:builtin => true)}
    scope :of_custom, ->{where(:builtin => false)}

    #系统生成二维码：指由系统创建而成的二维码，如桌台对应的二维码
    #非系统生成二维码：即：自定义二维码。是指用户自己创建的有自身特定用途的二维码
    validates :owner, presence:true, if: :owner_must_exist
    validates :name, presence:true

    set_shop_from :owner


    before_validation :set_slug


    def owner
      if self.owner_type == "Ddt::Order"
        @owner ||= OrderService::Order::Base.find(self.owner_id)
      else
        super
      end
    end

    def scan_by(user)
        self.increment!(:scan_times)
        self.qrcode_scan_relations.where(scaner: user).first_or_create!
    end

    def scaners
      qrcode_scan_relations.includes(:scaner).map(&:scaner)
    end

    def enable
      update(is_enable: true)
    end

    def disable
      update(is_enable: false)
    end


    def self.generate_slug
      rand(36**10).to_s(36)
    end

    protected

    def set_slug
      if self.slug.blank?
        self.slug = Ddt::BaseQrCodeScene.generate_slug
      end
    end

    def owner_must_exist
      return builtin? && type != "Ddt::VerifyVipInfoQrCodeScene"
    end

    def generate_qr_code(qr_url, options={})
      tmp_path = Rails.root.join('tmp', "#{'snap_' if options[:snap]}qr_code_scene_#{DateTime.now.to_i}#{Random.new_seed}.png")
      Ddt::QrcodeTool.generate_qrcode_image(qr_url, width=250).save(tmp_path)
      File.open(tmp_path, "rb") do |file|
        self.update_attribute(:url, file)
      end
    ensure
      File.delete(tmp_path) if tmp_path && File.exist?(tmp_path)
    end

  end
end
