# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Ddt::PaymentOrderPolicy do

  describe '#create?' do
    it_behaves_like 'an ApplicationPolicy permission', :payment_order, :create
  end
end
