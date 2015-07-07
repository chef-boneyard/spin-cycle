default[:machines] = {
  ubuntu_base: { ami: 'ami-b33dccf7', user: 'ubuntu', recipe: 'stress::ubuntu_base'},
  ubuntu_sugar: { ami: 'ami-b33dccf7', user: 'ubuntu', recipe: 'stress::sugar'},
  ubuntu_poise_ruby: { ami: 'ami-b33dccf7', user: 'ubuntu', recipe: 'stress::poise_ruby'},
  centos_base: { ami: 'ami-57cfc412', user: 'root', recipe: 'stress::centos_base'},
  centos_poise_ruby: { ami: 'ami-57cfc412', user: 'root', recipe: 'stress::poise_ruby'},
  windows_base: { ami: 'ami-876983c3', user: 'root', recipe: 'stress::windows_base', windows: true, instance_type: 'm3.medium'}
}

