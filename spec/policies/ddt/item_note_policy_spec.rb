# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Ddt::ItemNotePolicy do

  describe '#show?' do
    it_behaves_like 'an ApplicationPolicy permission', :item_note, :show
  end

  describe '#create?' do
    it_behaves_like 'an ApplicationPolicy permission', :item_note, :create
  end

  describe '#update?' do
    it_behaves_like 'an ApplicationPolicy permission', :item_note, :update
  end

  describe '#destroy?' do
    it_behaves_like 'an ApplicationPolicy permission', :item_note, :destroy
  end
end
