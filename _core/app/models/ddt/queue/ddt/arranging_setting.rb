# encoding:utf-8
module Ddt
  class ArrangingSetting < Ddt::Base
    include BelongsToBranchWithTouch
    include Ddt::Scanable
    acts_as_type :mode, [:auto_assigned, :free_choice], %W[系统自动分配 用户自主选择]

    def allow_scan?(user=nil)
      true
    end
    # 用于create_qr_code_scene
    def name
      self.id
    end

    # 当用户扫码后目标对象为该model时，系统自动跳转的路由地址
    def weixin_path
      "/queue?_ng_path=/branches/#{branch_id}/guest_queue"
    end
  end
end
