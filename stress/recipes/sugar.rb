include_recipe 'chef-sugar'

log "Chef Sugar tells us we're in the cloud" do
  only_if { cloud? }
end

raise 'exploderama'
