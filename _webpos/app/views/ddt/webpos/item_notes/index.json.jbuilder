
json.item_notes do
  json.array! @item_notes do |item_note|
    json.(item_note, :id, :name)
    if item_note.tag_ids.present?
      json.tag_ids item_note.tag_ids
    else
      json.tag_ids [-1]
    end
  end
end

json.tags do
  json.array! @tags, :id, :name
end
