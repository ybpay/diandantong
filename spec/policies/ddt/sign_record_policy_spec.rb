# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Ddt::SignRecordPolicy do

  describe '#show?' do
    it_behaves_like 'an ApplicationPolicy permission', :sign_record, :show
  end
end
