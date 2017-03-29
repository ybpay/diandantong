json.extract! location, :latitude, :longitude
json.created_at location.created_at.strftime("%Y-%m-%d %H:%M")
