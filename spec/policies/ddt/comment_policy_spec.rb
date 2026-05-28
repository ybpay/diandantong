# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Ddt::CommentPolicy do

  describe '#show?' do
    it_behaves_like 'an ApplicationPolicy permission', :comment, :show
  end

  describe '#reply?' do
    it_behaves_like 'an ApplicationPolicy permission', :comment, :reply
  end

  describe '#update?' do
    it_behaves_like 'an ApplicationPolicy permission', :comment, :update
  end
end
