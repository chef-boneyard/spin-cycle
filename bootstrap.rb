require 'chef/provisioning/aws_driver'

with_driver 'aws:default:us-west-1'

with_chef_server node[:bootstrap_url],
  client_name: node[:bootstrap_client],
  signing_key_filename: node[:bootstrap_key]

aws_key_pair node['ssh_key'] do
  private_key_path ::File.expand_path("~/.ssh/#{node['ssh_key']}")
  allow_overwrite true
end

machine 'provisioner' do
  machine_options convergence_options: { chef_version: node['chef_client_version'] },
    bootstrap_options: {iam_instance_profile: { name: 'spincycle_provisioner'}, key_name: node['ssh_key']},
    transport_options: {ssh_options: { use_agent: true}}
  action :setup
end

machine_execute 'make ssh dir' do
  command 'mkdir -p /home/ubuntu/.ssh && chown -R ubuntu: /home/ubuntu/.ssh && chmod 0700 /home/ubuntu/.ssh'
  machine 'provisioner'
end

machine_file "/home/ubuntu/.ssh/#{node['ssh_key']}" do
  local_path ::File.expand_path("~/.ssh/#{node['ssh_key']}")
  mode "0600"
  owner 'ubuntu'
  machine 'provisioner'
end

machine 'provisioner' do
  attributes chef_client_version: node["chef_client_version"], ssh_key: node['ssh_key']
  recipe 'stress'
  converge true
end

