class AddUseSceneToPrinters < ActiveRecord::Migration
  def change
    unless column_exists? :ddt_printers, :use_scene
      add_column :ddt_printers, :use_scene, :string
      Ddt::Printer.where(is_print_all: true).update_all(use_scene: :webpos)
      Ddt::Printer.where(is_print_all: false).update_all(use_scene: :kitchen)
    end
  end
end
