class FixPayMethodOfTickAccount < ActiveRecord::Migration
  def change
    Ddt::PayMethod.where(name: "挂帐").update_all("name='挂账'")
  end
end
