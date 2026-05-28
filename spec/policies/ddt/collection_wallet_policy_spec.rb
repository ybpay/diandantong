# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Ddt::CollectionWalletPolicy do

  describe '#show?' do
    it_behaves_like 'an ApplicationPolicy permission', :collection_wallet, :show
  end

  describe '#withdraw?' do
    it_behaves_like 'an ApplicationPolicy permission', :collection_wallet, :withdraw
  end
end
