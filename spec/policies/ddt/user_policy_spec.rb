# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Ddt::UserPolicy do

  describe '#show?' do
    it_behaves_like 'an ApplicationPolicy permission', :user, :show
  end

  describe '#update?' do
    it_behaves_like 'an ApplicationPolicy permission', :user, :update
  end

  describe '#recharge_card_wallet?' do
    it_behaves_like 'an ApplicationPolicy permission', :user, :recharge_card_wallet
  end

  describe '#exchange_card_wallet?' do
    it_behaves_like 'an ApplicationPolicy permission', :user, :exchange_card_wallet
  end

  describe '#exchange_credits_wallet?' do
    it_behaves_like 'an ApplicationPolicy permission', :user, :exchange_credits_wallet
  end

  describe '#get_credits_wallet?' do
    it_behaves_like 'an ApplicationPolicy permission', :user, :get_credits_wallet
  end

  describe '#send_coupon?' do
    it_behaves_like 'an ApplicationPolicy permission', :user, :send_coupon
  end

  describe '#create?' do
    it_behaves_like 'an ApplicationPolicy permission', :user, :create
  end

  describe '#destroy?' do
    it_behaves_like 'an ApplicationPolicy permission', :user, :destroy
  end
end
