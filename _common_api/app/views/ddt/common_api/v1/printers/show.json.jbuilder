json.extract! @printer, :id, :name, :number, :type, :api_key, :member_code, :phone, :enable, :times, :token, :is_print_all, :print_one_by_one, :use_scene, :print_spec, :print_per_product

json.types_collection Ddt::Printer.type_collection
json.scenes_collection Ddt::Printer.use_scene_collection
json.print_specs_collection Ddt::Printer.print_spec_collection