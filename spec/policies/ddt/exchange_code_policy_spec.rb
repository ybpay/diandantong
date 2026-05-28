# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Ddt::ExchangeCodePolicy do

  describe '#show?' do
    it_behaves_like 'an ApplicationPolicy permission', :exchange_code, :show
  end

  describe '#exchange?' do
    it_behaves_like 'an ApplicationPolicy permission', :exchange_code, :exchange
  end
end
