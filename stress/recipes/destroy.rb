ruby_block 'delete' do
  block do
    node.run_state['successful_machines'].each do |bye|
      machine = Chef::Resource::Machine.new(bye, run_context)
      machine.ignore_failure true
      machine.run_action(:destroy)
    end
  end
end
