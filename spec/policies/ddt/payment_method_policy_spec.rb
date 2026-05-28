# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Ddt::PaymentMethodPolicy do

  describe '#show?' do
    it_behaves_like 'an ApplicationPolicy permission', :payment_method, :show
  end

  describe '#update?' do
    it_behaves_like 'an ApplicationPolicy permission', :payment_method, :update
  end
end
