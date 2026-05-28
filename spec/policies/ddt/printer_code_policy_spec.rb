# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Ddt::PrinterCodePolicy do

  describe '#show?' do
    it_behaves_like 'an ApplicationPolicy permission', :printer_code, :show
  end

  describe '#create?' do
    it_behaves_like 'an ApplicationPolicy permission', :printer_code, :create
  end

  describe '#update?' do
    it_behaves_like 'an ApplicationPolicy permission', :printer_code, :update
  end

  describe '#destroy?' do
    it_behaves_like 'an ApplicationPolicy permission', :printer_code, :destroy
  end
end
