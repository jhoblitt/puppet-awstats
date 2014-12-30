source 'https://rubygems.org'

if puppetversion = ENV['PUPPET_GEM_VERSION']
  gem 'puppet', puppetversion, :require => false
else
  gem 'puppet', :require => false
end

if RUBY_VERSION <= '1.8.7'
  gem 'i18n', '~> 0.6.11', :require => false
  gem 'mime-types', '~> 1.25.1', :require => false
  gem 'activesupport', '~> 3.2.21', :require => false
  gem 'nokogiri', '~> 1.5.10', :require => false
end

gem 'rake',                    :require => false
gem 'puppetlabs_spec_helper',  :require => false
gem 'puppet-lint', '>= 1.1.0', :require => false
gem 'puppet-syntax',           :require => false
gem 'rspec-puppet',
  :git     => 'https://github.com/rodjek/rspec-puppet.git',
  :ref     => '6ac97993fa972a15851a73d55fe3d1c0a85172b5',
  :require => false
# rspec 3 spews warnings with rspec-puppet 1.0.1
gem 'rspec-core', '~> 2.0',    :require => false
gem 'serverspec',              :require => false
gem 'beaker',                  :require => false
gem 'beaker-rspec',            :require => false
gem 'pry',                     :require => false

# vim:ft=ruby
