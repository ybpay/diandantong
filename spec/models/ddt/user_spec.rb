# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Ddt::User, type: :model do
  let(:shop) { create(:shop_with_boss) }

  describe 'associations' do
    it { should have_many(:wechat_users).dependent(:destroy) }
    it { should have_many(:wechat_share_records) }
    it { should have_many(:accounts) }
    it { should have_one(:merchant_apply) }
  end

  describe 'inherited from Ddt::BaseUser' do
    it 'is a BaseUser subclass' do
      expect(described_class.ancestors).to include(Ddt::BaseUser)
    end

    it 'includes Discard::Model via BaseUser' do
      expect(described_class.ancestors).to include(Discard::Model)
    end
  end

  describe '#select_json' do
    it 'returns id and name' do
      user = create(:user, shop: shop)
      json = user.select_json
      expect(json).to include(:id, :name)
      expect(json[:id]).to eq(user.id)
    end
  end

  describe 'Discard::Model' do
    it 'soft deletes a user' do
      user = create(:user, shop: shop)
      user.discard!
      expect(user.discarded?).to be true
      expect(described_class.with_discarded).to include(user)
      expect(described_class.all).not_to include(user)
    end
  end

  describe '#to_label' do
    it 'combines nickname, phone, email, and id' do
      user = create(:user, shop: shop, phone: '15000009999')
      expect(user.to_label).to be_present
    end

    it 'includes id as fallback' do
      user = create(:user, shop: shop)
      expect(user.to_label).to include(user.id.to_s)
    end
  end

  describe 'factory' do
    it 'creates a valid user' do
      user = create(:user, shop: shop)
      expect(user).to be_persisted
      expect(user.phone).to be_present
    end

    it 'sets correct type' do
      user = create(:user, shop: shop)
      expect(user.type).to eq('Ddt::User')
    end
  end
end
