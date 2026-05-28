# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Ddt::DdbModulePolicy do

  describe '#show?' do
    it_behaves_like 'an ApplicationPolicy permission', :ddb_module, :show
  end

  describe '#update?' do
    it_behaves_like 'an ApplicationPolicy permission', :ddb_module, :update
  end
end
