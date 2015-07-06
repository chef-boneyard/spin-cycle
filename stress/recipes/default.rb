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

# machine_batch 'ubuntu' do
  test_machine 'ubuntu_base' do
    ami 'ami-b33dccf7'
    ssh_username 'ubuntu'
    recipe 'stress::ubuntu_base'
  end
# end

# machine_batch 'centos' do
  test_machine 'centos_base' do
    ami 'ami-57cfc412'
    ssh_username 'root'
    recipe 'stress::centos_base'
  end
# end

# machine_batch 'windows' do
  test_machine 'windows_base' do
    ami 'ami-876983c3'
    instance_type 'm3.medium'
    windows true
    recipe 'stress::windows_base'
  end
# end
include_recipe 'stress::destroy'
