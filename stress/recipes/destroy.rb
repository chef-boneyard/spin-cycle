machine_batch 'bye' do
  machines node['machines'].keys
  action :destroy
  ignore_failure true
end
