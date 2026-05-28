# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Ddt::CardWalletPolicy do

  describe '#manage?' do
    it_behaves_like 'an ApplicationPolicy permission', :card_wallet, :manage
  end
end
