class FixComboPackageItemAdjustments3 < ActiveRecord::Migration
  def change
    ['adjustment_total', 'apportion_adjustment_total', 'not_actual_amount'].each do |adjustment_name|
      Ddt::LineItem.where(itemable_type: 'Ddt::ComboPackage', deleted_at: nil).where("#{adjustment_name} != 0").find_each do |line_item|
        set_adjustments(line_item)
      end
      puts "Migrate of #{adjustment_name} done! fixed size: #{(@fixed_ids || []).size}"
    end
  end


  def set_adjustments(line_item)
    @fixed_ids ||= []
    return if @fixed_ids.include?(line_item.id)
    Ddt::ComboPackageItem.set_adjustments(line_item)
    @fixed_ids << line_item.id
  end
end
