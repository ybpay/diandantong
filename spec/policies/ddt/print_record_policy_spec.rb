# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Ddt::PrintRecordPolicy do

  describe '#show?' do
    it_behaves_like 'an ApplicationPolicy permission', :print_record, :show
  end
end
