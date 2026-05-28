# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Ddt::CsBranchBindingPolicy do

  describe '#show?' do
    it_behaves_like 'an ApplicationPolicy permission', :cs_branch_binding, :show
  end

  describe '#update?' do
    it_behaves_like 'an ApplicationPolicy permission', :cs_branch_binding, :update
  end
end
