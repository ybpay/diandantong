# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Ddt::PrinterPolicy do

  describe '#show?' do
    it_behaves_like 'an ApplicationPolicy permission', :printer, :show
  end

  describe '#create?' do
    it_behaves_like 'an ApplicationPolicy permission', :printer, :create
  end

  describe '#update?' do
    it_behaves_like 'an ApplicationPolicy permission', :printer, :update
  end

  describe '#destroy?' do
    it_behaves_like 'an ApplicationPolicy permission', :printer, :destroy
  end
end
