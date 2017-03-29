require "test_helper"
module Ddt
  class ShipmentTest < TestCase::Base
    let(:address){ create :address, base_user: user }
    let(:shipment){ Ddt::Shipment.new(branch: branch, shop: shop, address: address)}
    def test_address_info
      assert_equal address.name, shipment.name
      assert_equal address.phone, shipment.phone
      assert_equal address.content, shipment.content
    end

    def test_cost
      skip # TODO
    end
  end
end