# frozen_string_literal: true

configure_beaker do |host|
  install_module_from_forge_on(host, 'puppet/epel', '> 4 < 5')
  install_module_from_forge_on(host, 'puppetlabs/apache', '> 8 < 9')
  install_module_from_forge_on(host, 'puppet/yum', '> 5 < 7')
end
