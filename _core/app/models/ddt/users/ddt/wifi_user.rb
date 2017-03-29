module Ddt
  class WifiUser < Ddt::BaseUser

    ### relationships

    ### validations
    validates :wifi_code, presence: true

    ### callbacks

    ### scopes

    ### methods

    # Wifi用户不需要验证是否有后台账号
    def is_account_user?
      return false
    end

    # 与 pre_order 的同名方法，为了节省判断代码，其实是删除绑定在 for_wifi_order 下的 order_itemables
    def clear_pre_order_itemables(branch)
        self.order_itemables.for_wifi_order.where(branch: branch).delete_all
    end
    
  end
end