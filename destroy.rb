require 'chef/provisioning/aws_driver'

with_driver 'aws:default:us-west-1'

with_chef_server node[:bootstrap_url],
  client_name: node[:bootstrap_client],
  signing_key_filename: node[:bootstrap_key]

machine 'provisioner' do
  action :destroy
end
