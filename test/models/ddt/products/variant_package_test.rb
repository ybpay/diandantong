require "test_helper"
module Ddt
  class VariantPackageTest < TestCase::Base
    include ItemableTest
    let(:weight_variant){ create(:product, by_weight: true).master }
    let(:itemable){ VariantPackage.new(variant: weight_variant, weight: 2.1) }
    setup do
    end
  end
end