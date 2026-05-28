# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Ddt::Product, type: :model do
  let(:shop) { create(:shop_with_boss) }
  let(:branch) { shop.branches.first }

  describe 'associations' do
    it { should have_one(:master).class_name('Ddt::Variant').with_options(is_master: true) }
    it { should have_many(:variants).class_name('Ddt::Variant') }
    it { should have_many(:product_option_types) }
    it { should have_many(:option_types).through(:product_option_types) }
    it { should have_and_belong_to_many(:categories) }
  end

  describe 'validations' do
    it { should validate_presence_of(:name) }
    it { should validate_presence_of(:unit_name) }
  end

  describe 'included modules' do
    it 'includes Discard::Model' do
      expect(described_class.ancestors).to include(Discard::Model)
    end
  end

  describe 'default scope' do
    it 'orders by position ascending' do
      product1 = create(:product, shop: shop, branch: branch, position: 2)
      product2 = create(:product, shop: shop, branch: branch, position: 1)
      expect(branch.products.reload.to_a.first).to eq(product2)
    end
  end

  describe '#has_variants?' do
    it 'returns false when only master variant exists' do
      product = create(:product, shop: shop, branch: branch)
      expect(product.has_variants?).to be false
    end

    it 'returns true when non-master variants exist' do
      product = create(:product, shop: shop, branch: branch)
      create(:variant, product: product, is_master: false, price: 20.0)
      expect(product.has_variants?).to be true
    end
  end

  describe 'master variant' do
    it 'is automatically created after product creation' do
      product = create(:product, shop: shop, branch: branch)
      expect(product.master).to be_present
      expect(product.master.is_master).to be true
    end

    it 'inherits the product price' do
      product = create(:product, shop: shop, branch: branch, price: 35.0)
      expect(product.master.price.to_f).to eq(35.0)
    end
  end

  describe '.set_on_shelf / .set_off_shelf' do
    let(:product) { create(:product, shop: shop, branch: branch) }

    it 'sets product on shelf' do
      described_class.set_on_shelf(product.id)
      expect(product.reload.on_shelf).to be_truthy
    end

    it 'sets product off shelf' do
      described_class.set_off_shelf(product.id)
      expect(product.reload.on_shelf).to be_falsey
    end
  end

  describe 'Discard::Model' do
    it 'soft deletes a product' do
      product = create(:product, shop: shop, branch: branch)
      product.discard!
      expect(product.discarded?).to be true
      expect(branch.products.with_discarded).to include(product)
      expect(branch.products).not_to include(product)
    end
  end

  describe 'factory' do
    it 'creates a valid product with master variant' do
      product = create(:product, shop: shop, branch: branch)
      expect(product).to be_persisted
      expect(product.name).to be_present
      expect(product.master).to be_present
    end

    it 'creates product with correct price' do
      product = create(:product, shop: shop, branch: branch, price: 42.5)
      expect(product.price.to_f).to eq(42.5)
    end
  end
end

RSpec.describe Ddt::Category, type: :model do
  let(:shop) { create(:shop_with_boss) }
  let(:branch) { shop.branches.first }

  describe 'associations' do
    it { should have_and_belong_to_many(:products) }
    it { should have_many(:subs).dependent(:destroy) }
    it { should belong_to(:parent).optional }
  end

  describe 'validations' do
    it { should validate_presence_of(:name) }
  end

  describe 'included modules' do
    it 'includes Discard::Model' do
      expect(described_class.ancestors).to include(Discard::Model)
    end
  end

  describe 'hierarchical structure' do
    it 'allows root categories (no parent)' do
      category = create(:category, shop: shop, branch: branch)
      expect(category.parent).to be_nil
      expect(category.depth).to eq(0)
    end

    it 'allows child categories' do
      parent = create(:category, shop: shop, branch: branch)
      child = create(:category, shop: shop, branch: branch, parent: parent)
      expect(child.parent).to eq(parent)
      expect(child.depth).to eq(1)
    end

    it 'provides name_with_parent for nested categories' do
      parent = create(:category, shop: shop, branch: branch, name: '主菜')
      child = create(:category, shop: shop, branch: branch, parent: parent, name: '牛肉')
      expect(child.name_with_parent).to be_present
    end
  end

  describe 'scopes' do
    let!(:root_cat) { create(:category, shop: shop, branch: branch) }
    let!(:child_cat) { create(:category, shop: shop, branch: branch, parent: root_cat) }

    it '.root returns only root categories' do
      expect(described_class.root).to include(root_cat)
      expect(described_class.root).not_to include(child_cat)
    end

    it 'defaults to ordering by position' do
      cat2 = create(:category, shop: shop, branch: branch, position: 1)
      cat1 = create(:category, shop: shop, branch: branch, position: 2)
      expect(described_class.all.first).to eq(cat2)
    end
  end

  describe '#subs_with_self' do
    it 'returns self and all subs' do
      parent = create(:category, shop: shop, branch: branch)
      child = create(:category, shop: shop, branch: branch, parent: parent)
      result = parent.subs_with_self
      expect(result).to include(parent, child)
    end
  end

  describe 'Discard::Model' do
    it 'soft deletes a category' do
      category = create(:category, shop: shop, branch: branch)
      category.discard!
      expect(category.discarded?).to be true
      expect(described_class.with_discarded).to include(category)
      expect(described_class.all).not_to include(category)
    end
  end

  describe 'factory' do
    it 'creates a valid category' do
      category = create(:category, shop: shop, branch: branch)
      expect(category).to be_persisted
      expect(category.name).to be_present
    end
  end
end
