class FixPercentOfActual < ActiveRecord::Migration
  def change
    Ddt::PayMethod.where(is_actual: false).update_all(percent_of_actual: 0)
  end
end
