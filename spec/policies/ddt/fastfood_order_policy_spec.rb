# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Ddt::FastfoodOrderPolicy do

  describe '#create?' do
    it_behaves_like 'an ApplicationPolicy permission', :fastfood_order, :create
  end

  describe '#call_customer?' do
    it_behaves_like 'an ApplicationPolicy permission', :fastfood_order, :call_customer
  end

  describe '#create_and_pay?' do
    it_behaves_like 'an ApplicationPolicy permission', :fastfood_order, :create_and_pay
  end
end
