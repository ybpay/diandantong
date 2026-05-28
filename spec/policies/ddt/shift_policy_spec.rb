# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Ddt::ShiftPolicy do

  describe '#show?' do
    it_behaves_like 'an ApplicationPolicy permission', :shift, :show
  end
end
