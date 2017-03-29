class FixWebposPrinter < ActiveRecord::Migration
  def change
    printers = []
    Ddt::Printer.where(use_scene: :webpos).find_each do |printer|
      size = printers.size
      if size == 3000
        import(printers)
        printers = []
        puts ">>>>> Import printers, printer: #{printer.id}"
      end
      printers << copy(printer)
      if (size + 1)%100 == 0
        puts "--->>#{size+1}th Copy printer: #{printer.id}"
      end
    end
    if printers.size > 0
      import(printers)
    end
  end

  def import(printers)
    Ddt::Printer.import(printers, validate: false)
  end

  def copy(printer)
    black_list = [:id, :created_at, :updated_at]
    attrs = {}
    printer.attributes.each do |k, v|
      k = k.to_sym
      if !black_list.include? k
        attrs[k] = v
      end
    end
    attrs[:use_scene] = 'guest'
    attrs[:name] = "#{attrs[:name]}-(客)"
    #Model::OrderChangeLog.import(order_change_logs, validate: false)
    Ddt::Printer.new(attrs)
  end
end
