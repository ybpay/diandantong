# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Ddt::VoucherPolicy do

  describe '#show?' do
    it_behaves_like 'an ApplicationPolicy permission', :voucher, :show
  end

  describe '#exchange?' do
    it_behaves_like 'an ApplicationPolicy permission', :voucher, :exchange
  end
end
