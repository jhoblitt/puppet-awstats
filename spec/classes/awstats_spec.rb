# frozen_string_literal: true

require 'spec_helper'

shared_examples 'geoip package' do |facts|
  case facts[:os]['family']
  when 'Debian'
    it { is_expected.to contain_package('libgeo-ip-perl') }
  when 'RedHat'
    case facts[:os]['release']['major']
    when '9'
      it { is_expected.to contain_package('perl-GeoIP2') }
    else
      it { is_expected.to contain_package('perl-Geo-IP') }
    end
  end
end

shared_examples 'decodecutfkeys package' do |facts|
  case facts[:os]['family']
  when 'Debian'
    it { is_expected.to contain_package('liburi-perl') }
  when 'RedHat'
    it { is_expected.to contain_package('perl-URI') }
  end
end

describe 'awstats', type: :class do
  on_supported_os.each do |os, facts|
    context "on #{os}" do
      let(:facts) do
        facts
      end

      context 'default params' do
        it { is_expected.to contain_package('awstats') }

        it do
          is_expected.to contain_file('/etc/awstats').with(
            ensure: 'directory',
            owner: 'root',
            group: 'root',
            mode: '0755',
            recurse: true,
            purge: false
          )
        end

        it { is_expected.to contain_file('/etc/awstats').that_requires('Package[awstats]') }
      end

      context 'config_dir_purge =>' do
        context 'true' do
          let(:params) { { config_dir_purge: true } }

          it { is_expected.to contain_package('awstats') }

          it do
            is_expected.to contain_file('/etc/awstats').with(
              ensure: 'directory',
              owner: 'root',
              group: 'root',
              mode: '0755',
              recurse: true,
              purge: true
            )
          end

          it { is_expected.to contain_file('/etc/awstats').that_requires('Package[awstats]') }
        end

        context 'false' do
          let(:params) { { config_dir_purge: false } }

          it { is_expected.to contain_package('awstats') }

          it do
            is_expected.to contain_file('/etc/awstats').with(
              ensure: 'directory',
              owner: 'root',
              group: 'root',
              mode: '0755',
              recurse: true,
              purge: false
            )
          end

          it { is_expected.to contain_file('/etc/awstats').that_requires('Package[awstats]') }
        end
      end

      context 'enable_plugins =>' do
        context "[ 'decodeutfkeys' ]" do
          let(:params) { { enable_plugins: ['decodeutfkeys'] } }

          include_examples 'decodecutfkeys package', facts

          it { is_expected.to contain_class('awstats::plugin::decodeutfkeys') }
        end

        context "[ 'geoip' ]" do
          let(:params) { { enable_plugins: ['geoip'] } }

          include_examples 'geoip package', facts

          it { is_expected.to contain_class('awstats::plugin::geoip') }
        end

        # check case insensitivity and multiple enable_plugins
        context "[ 'DECODEUTFKEYS', 'GEOIP' ]" do
          let(:params) { { enable_plugins: %w[DECODEUTFKEYS GEOIP] } }

          include_examples 'geoip package', facts
          include_examples 'decodecutfkeys package', facts

          it { is_expected.to contain_class('awstats::plugin::decodeutfkeys') }
          it { is_expected.to contain_class('awstats::plugin::geoip') }
        end
      end
    end
  end

  context 'on osfamily Solaris' do
    let(:facts) do
      {
        os: {
          'family' => 'Solaris',
        },
      }
    end

    it 'fails' do
      is_expected.to raise_error Puppet::Error, %r{not supported on Solaris}
    end
  end
end
