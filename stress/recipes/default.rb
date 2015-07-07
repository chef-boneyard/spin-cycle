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

node['machines'].each_pair do |name, obj|
  test_machine name do
    ami obj[:ami]
    ssh_username obj[:user]
    recipe obj[:recipe]
    windows obj[:windows] || false
    instance_type obj[:instance_type] if obj[:instance_type]
  end
end

ruby_block 'delete' do
  block do
    mb = Chef::Resource::MachineBatch.new('byebye', run_context)
    mb.machines node.run_state['successful_machines']
    mb.ignore_failure true
    mb.run_action(:destroy)
  end
end

ruby_block 'failed machines' do
  block do
    node.run_state['failed_machines'].each_pair do |name, err|
      Chef::Log.info("Node #{name} failed with #{err.message}")
    end
  end
end
