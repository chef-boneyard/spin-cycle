node.set["build-essential"]["compile_time"] = true
node.set['apt']['compile_time_update'] = true
include_recipe 'apt'
include_recipe 'build-essential'
package('libxslt1-dev') { action :nothing }.run_action(:install)
package('zlib1g-dev') { action :nothing }.run_action(:install)
package('liblzma-dev') { action :nothing }.run_action(:install)

chef_gem 'chef-provisioning-aws' do
  compile_time true
end

begin
require 'chef/provisioning/aws_driver'
rescue LoadError
  puts "will load c-p-a later"
end

iam = AWS::Core::CredentialProviders::EC2Provider.new

with_driver('aws:IAM:us-west-1', aws_credentials: { 'IAM' => iam.credentials})

aws_key_pair node['ssh_key'] do
  private_key_path ::File.expand_path("~/.ssh/#{node['ssh_key']}")
end

machine_batch 'ubuntu' do
  machine 'ubuntu_base' do
    machine_options convergence_options: { chef_version: node['chef_client_version'] },
      bootstrap_options: { key_name: node['ssh_key']}
    recipe 'stress::ubuntu_base'
    converge true
  end
end

machine_batch 'centos' do
  machine 'centos_base' do
    machine_options convergence_options: { chef_version: node['chef_client_version'] },
      bootstrap_options: { image_id: 'ami-57cfc412', key_name: node['ssh_key']}, ssh_username: 'root'
    recipe 'stress::centos_base'
    converge true
  end
end

machine_batch 'windows' do
  machine 'windows_base' do
    machine_options convergence_options: { chef_version: node['chef_client_version'] },
      bootstrap_options: { image_id: 'ami-876983c3', instance_type: 'm3.medium', key_name: node['ssh_key']}, is_windows: true
    recipe 'stress::windows_base'
    converge true
  end
end
include_recipe 'stress::destroy'
