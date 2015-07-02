%w( ubuntu_base centos_base ).each do |bye|
  machine bye do
    action :destroy
    ignore_failure true
  end
end
