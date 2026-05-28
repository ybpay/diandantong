# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Ddt::CookPolicy do

  describe '#manage?' do
    it_behaves_like 'an ApplicationPolicy permission', :cook, :manage
  end
end
