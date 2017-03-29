module Ddt
  class CsBranchBinding < Ddt::Base
    belongs_to :shop, class_name: 'Ddt::Shop'
    belongs_to :branch, -> { with_deleted }, class_name: 'Ddt::Branch'
    replicated_model

    validates_format_of :http_proxy_url, :with => /\A(http|https):\/\/.*\z/i, allow_blank: true
    before_create :initialize_token
    after_commit :notify_refresh_binding, on: :create
    after_update :notify_force_online_changed, on: :update, if: :force_online_changed?

    auto_strip_attributes :http_proxy_url, :delete_whitespaces => true

    def can_place_online?
      self.online || self.force_online
    end

    def self.deny_online_access?(branch, request)
      is_from_cs = request.headers['Access-From'] == 'CS'
      if is_from_cs
        return false
      else
        binding = branch.try(:cs_branch_binding)
        return binding.present? && !binding.can_place_online?
      end
    end

    private

    def initialize_token
      self.shop_id = self.branch.shop_id
      self.token = "CS-#{shop_id}-#{branch_id}-DEFAULT-TOKEN"
    end

    def notify_refresh_binding
      Ddt::CloudServer.post('setup', 'refresh', query_params: {
          branch_id: self.branch_id
      }) rescue nil
    end

    def notify_force_online_changed
      Ddt::CloudServer.post('sync', 'force-online',
                                 path_params: {
                                     shop_id: self.shop_id,
                                     branch_id: self.branch_id
                                 },
                                 query_params: {
                                     force_online: self.force_online
                                 }) rescue nil
    end
  end
end
