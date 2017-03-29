class AddExchangeCodeIndex < ActiveRecord::Migration
  def change
    add_index :ddt_exchange_codes, :code, name: "index_ddt_exchange_codes_on_code", :length => {:code => 191}
  end
end
