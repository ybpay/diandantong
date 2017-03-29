module Ddt
  class QrCodeAssignLog < Ddt::Base
    include BelongsToBranch
    has_many :qr_code_scenes, class_name: 'Ddt::QrCodeScene'
    validates_presence_of :shop, :branch, :count
    validates_numericality_of :count, :greater_than => 0, :less_than_or_equal_to => 100

    validate :check_shop_and_branch, on: :create 
    after_create :assign_qr_code_scene

    default_scope ->{ order(id: :desc) }


    def note 
      self.qr_code_scenes.map{|q| [q.id, q.qr_url].join(', ')}.join("<br/>")
    end

    private
    def assign_qr_code_scene
      qr_code_scenes = Ddt::QrCodeScene
          .where(qr_code_assign_log_id: nil, branch_id: nil, shop_id: nil)
          .limit(count)
      qr_code_scenes.update_all(branch_id: self.branch_id, shop_id: self.shop_id, qr_code_assign_log_id: self.id, updated_at: DateTime.now)
    end

    def check_shop_and_branch
      if count.present? && Ddt::QrCodeScene.where(qr_code_assign_log_id: nil, branch_id: nil, shop_id: nil).count < count
          self.errors[:count] = "剩余免费二维码不足#{count}个"
          return
      end
      
      branch = shop.branches.find(self.branch_id) rescue nil
      if branch.blank? || branch.shop_id != self.shop_id
        self.errors[:branch_id] = '门店ID与点账号不匹配'
        return
      end
    end
  end
end