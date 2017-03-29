json.extract! agent, :id, :agent_no, :name, :phone, :balance, :email
json.agent_rels agent.agent_rels do |agent_rel|
  json.agent_from agent_rel.agent_from.strftime("%F")
  json.agent_to agent_rel.agent_to.strftime("%F")
  json.agent_zone_name agent_rel.agent_zone.name
end