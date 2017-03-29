FactoryGirl.define do
  [:flat_percent, :flat_rate, :flat_reduce, :tiered_flat_rate, :tiered_percent, :tiered_reduce].each do |name|
    factory "calculator_order_#{name}", class: Ddt::Calculator::Order.const_get(name.to_s.camelize) do
    end
  end
end
