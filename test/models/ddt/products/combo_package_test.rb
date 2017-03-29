require "test_helper"
module Ddt
  class ComboPackageTest < TestCase::Base
    include ItemableTest
    let(:itemable){ create(:combo_with_package).combo_packages.first }
    setup do
    end
  end
end