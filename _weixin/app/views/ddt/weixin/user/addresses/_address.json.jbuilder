json.extract! address, :id, :name, :phone, :building, :room_no, :is_default, :city_name, :content
json.longitude address.longitude.to_f
json.latitude address.latitude.to_f