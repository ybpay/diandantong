# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Ddt::GrouponPolicy do

  describe '#show?' do
    it_behaves_like 'an ApplicationPolicy permission', :groupon, :show
  end

  describe '#exchange?' do
    it_behaves_like 'an ApplicationPolicy permission', :groupon, :exchange
  end
end
