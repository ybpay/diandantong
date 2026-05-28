# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Ddt::MerchantApplyPolicy do

  describe '#manage?' do
    it_behaves_like 'an ApplicationPolicy permission', :merchant_apply, :manage
  end
end
