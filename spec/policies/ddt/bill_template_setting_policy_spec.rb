# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Ddt::BillTemplateSettingPolicy do

  describe '#show?' do
    it_behaves_like 'an ApplicationPolicy permission', :bill_template_setting, :show
  end

  describe '#update?' do
    it_behaves_like 'an ApplicationPolicy permission', :bill_template_setting, :update
  end
end
