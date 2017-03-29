json.array! @feature_module_groups do |feature_module_group|
  json.name feature_module_group[:name]
  json.price feature_module_group[:price]
  json.label feature_module_group[:label]
  json.description Ddt::FeatureModuleGroup.version_description(feature_module_group)
  json.modules feature_module_group[:modules]
  json.charge_by_branch feature_module_group[:charge_by_branch]
end