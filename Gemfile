source 'https://rubygems.org'

if puppetversion = ENV['PUPPET_GEM_VERSION']
  gem 'puppet', puppetversion, :require => false
else
  gem 'puppet', :require => false
end

gem 'rake',                   :require => false
gem 'puppetlabs_spec_helper', :require => false
gem 'puppet-lint',            :require => false
gem 'puppet-syntax',          :require => false
# for "pretty" content diff merged post 1.0.1 (current latest)
gem 'rspec-puppet',
  :git     => 'https://github.com/rodjek/rspec-puppet.git',
  :ref     => '93773d3cda0a8be016882cf25fc26d6a358c9bf7',
  :require => false
gem 'rspec',  '< 3',          :require => false
gem 'serverspec',             :require => false
gem 'beaker',                 :require => false
gem 'beaker-rspec',           :require => false
gem 'pry',                    :require => false
