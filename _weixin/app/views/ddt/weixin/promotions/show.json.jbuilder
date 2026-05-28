json.extract! @promotion, :id, :name, :keywords, :description, :starts_at, :expires_at, :hide_header_in_weixin, :usage_limit, :usable_in_all_branches

json.image @promotion.image_variant(:medium)

if @promotion.usable_in_all_branches
  json.active_branches_label  @promotion.active_branches_label
else
  json.active_branches do
    json.partial! partial: '/ddt/weixin/branches/branches', locals: { branches: @promotion.active_branches } 
  end
end

