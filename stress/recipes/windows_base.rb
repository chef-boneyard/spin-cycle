include_recipe 'chocolatey'

%w(sysinternals 7zip).each do |pkg|
  chocolatey pkg
end
