class Chef::Resource::TestMachine < Chef::Resource::LWRPBase
  self.resource_name = :test_machine
  provides :test_machine if Chef::Resource.respond_to?(:provides)

  actions :converge
  default_action :converge

  attribute :name, kind_of: String, name_attribute: true
  attribute :recipe, kind_of: String, default: nil
  attribute :ssh_username, kind_of: String, default: nil
  attribute :ami, kind_of: String, default: nil
  attribute :instance_type, kind_of: String, default: 't2.micro'
  attribute :windows, kind_of: [TrueClass, FalseClass], default: false
end

class Chef::Provider::TestMachine < Chef::Provider::LWRPBase
  provides :test_machine if Chef::Provider.respond_to?(:provides)

  use_inline_resources

  def whyrun_supported?
    true
  end

  action :converge do
    node.run_state['successful_machines'] ||= []
    node.run_state['failed_machines'] ||= []

    machine new_resource.name do
      machine_options convergence_options: { chef_version: node['chef_client_version'] },
        bootstrap_options: {
        image_id: new_resource.ami,
        key_name: node['ssh_key'],
        instance_type: new_resource.instance_type
      }, ssh_username: new_resource.ssh_username, is_windows: new_resource.windows
      recipe new_resource.recipe
      converge true
    end

    node.run_state['successful_machines'] << new_resource.name
  end
end
