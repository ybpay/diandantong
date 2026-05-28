# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Ddt::CreditsWalletPolicy do

  describe '#manage?' do
    it_behaves_like 'an ApplicationPolicy permission', :credits_wallet, :manage
  end
end
