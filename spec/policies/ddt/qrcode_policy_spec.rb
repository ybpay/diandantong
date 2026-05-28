# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Ddt::QrcodePolicy do

  describe '#show?' do
    it_behaves_like 'an ApplicationPolicy permission', :qrcode, :show
  end

  describe '#create?' do
    it_behaves_like 'an ApplicationPolicy permission', :qrcode, :create
  end

  describe '#update?' do
    it_behaves_like 'an ApplicationPolicy permission', :qrcode, :update
  end

  describe '#destroy?' do
    it_behaves_like 'an ApplicationPolicy permission', :qrcode, :destroy
  end
end
