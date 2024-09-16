# frozen_string_literal: true

configure_beaker(modules: :metadata) do |host|
  install_puppet_module_via_pmt_on(host, 'puppet/epel', '4')
  install_puppet_module_via_pmt_on(host, 'puppetlabs/apache', '8')
  install_puppet_module_via_pmt_on(host, 'puppet/yum', '6')
end
