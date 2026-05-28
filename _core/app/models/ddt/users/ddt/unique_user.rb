module Ddt
  class UniqueUser < Ddt::Base
    include Discard::Model
    default_scope { kept }

    has_many :users, class_name: 'Ddt::User'
    validates :gonghao_open_id, presence: true, gonghao: true
    validates :user_open_id, uniqueness: true, presence: true

    def is_different_from(oauth_user_info)
      result = false
      %W[nickname sex province city country headimgurl unionid].each do |column|
          result ||= oauth_user_info[column.to_sym].present? && (self.send(column.to_sym) != oauth_user_info[column.to_sym])
      end
      result
    end

    def sex_name
      if self.sex == 1 
        I18n.t("unique_user.sex.male")
      elsif self.sex == 2
        I18n.t("unique_user.sex.female")
      else
        I18n.t("unique_user.sex.unknown")
      end
    end

    def region
      "#{self.province} #{city}"
    end
  end
end
