node['machines'].each do |bye|
  machine bye do
    action :destroy
    ignore_failure true
  end
end
