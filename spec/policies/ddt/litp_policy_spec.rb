# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Ddt::LitpPolicy do

  describe '#show?' do
    it_behaves_like 'an ApplicationPolicy permission', :litp, :show
  end

  describe '#confirm_litp?' do
    it_behaves_like 'an ApplicationPolicy permission', :litp, :confirm_litp
  end

  describe '#complete_litp?' do
    it_behaves_like 'an ApplicationPolicy permission', :litp, :complete_litp
  end
end
