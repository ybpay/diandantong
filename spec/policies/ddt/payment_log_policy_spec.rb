# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Ddt::PaymentLogPolicy do

  describe '#show?' do
    it_behaves_like 'an ApplicationPolicy permission', :payment_log, :show
  end
end
