class FixLisenceData < ActiveRecord::Migration
  def change
    Ddt::Lisence.where(lisence_type: [:single, :service]).update_all(lisence_type: :standard)
  end
end
