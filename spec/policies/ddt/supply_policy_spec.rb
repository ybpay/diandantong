# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Ddt::SupplyPolicy do

  describe '#show?' do
    it_behaves_like 'an ApplicationPolicy permission', :supply, :show
  end
end
