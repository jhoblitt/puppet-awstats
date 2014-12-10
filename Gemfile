source 'https://rubygems.org'

if puppetversion = ENV['PUPPET_GEM_VERSION']
  gem 'puppet', puppetversion, :require => false
else
  gem 'puppet', :require => false
end

gem 'rake',                    :require => false
gem 'puppetlabs_spec_helper',  :require => false
gem 'puppet-lint', '>= 1.1.0', :require => false
gem 'puppet-syntax',           :require => false
gem 'rspec-puppet',
  :git     => 'https://github.com/rodjek/rspec-puppet.git',
  :ref     => 'v2.0.0',
  :require => false
# rspec 3 spews warnings with rspec-puppet 1.0.1
gem 'rspec-core', '~> 2.0',    :require => false
gem 'serverspec',              :require => false
gem 'beaker',                  :require => false
gem 'beaker-rspec',            :require => false
gem 'pry',                     :require => false

# vim:ft=ruby
