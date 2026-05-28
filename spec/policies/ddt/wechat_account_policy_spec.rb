# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Ddt::WechatAccountPolicy do

  describe '#manage?' do
    it_behaves_like 'an ApplicationPolicy permission', :wechat_account, :manage
  end
end
