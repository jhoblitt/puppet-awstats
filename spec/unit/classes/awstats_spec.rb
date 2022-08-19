# frozen_string_literal: true

require 'spec_helper'

describe 'awstats', type: :class do
  context 'supported operating systems' do
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

          context '42' do
            let(:params) { { config_dir_purge: 42 } }

            it 'fails' do
              is_expected.to raise_error(Puppet::Error, %r{is not a boolean})
            end
          end
        end

        context 'enable_plugins =>' do
          context "[ 'decodeutfkeys' ]" do
            let(:params) { { enable_plugins: ['decodeutfkeys'] } }

            case facts[:osfamily]
            when 'Debian'
              it { is_expected.to contain_package('liburi-perl') }
            when 'RedHat'
              it { is_expected.to contain_package('perl-URI') }
            end

            it do
              is_expected.to contain_class('awstats::plugin::decodeutfkeys').
                that_comes_before('Anchor[awstats::end]')
            end
          end

          context "[ 'geoip' ]" do
            let(:params) { { enable_plugins: ['geoip'] } }

            case facts[:osfamily]
            when 'Debian'
              it { is_expected.to contain_package('libgeo-ip-perl') }
            when 'RedHat'
              it { is_expected.to contain_package('perl-Geo-IP') }
            end

            it do
              is_expected.to contain_class('awstats::plugin::geoip').
                that_comes_before('Anchor[awstats::end]')
            end
          end

          # check case insensitivity and multiple enable_plugins
          context "[ 'DECODEUTFKEYS', 'GEOIP' ]" do
            let(:params) { { enable_plugins: %w[DECODEUTFKEYS GEOIP] } }

            case facts[:osfamily]
            when 'Debian'
              it { is_expected.to contain_package('liburi-perl') }
              it { is_expected.to contain_package('libgeo-ip-perl') }
            when 'RedHat'
              it { is_expected.to contain_package('perl-URI') }
              it { is_expected.to contain_package('perl-Geo-IP') }
            end
          end

          context '42' do
            let(:params) { { enable_plugins: 42 } }

            it 'fails' do
              is_expected.to raise_error(Puppet::Error, %r{is not an Array})
            end
          end
        end
      end
    end

    context 'el5.x' do
      let(:facts) do
        {
          osfamily: 'RedHat',
          operatingsystem: 'RedHat',
          operatingsystemmajrelease: '5',
        }
      end

      it 'should fail' do
        should raise_error(Puppet::Error)
      end
    end
  end

  context 'on osfamily Solaris' do
    let(:facts) { { osfamily: 'Solaris', operatingsystem: 'Solaris' } }

    it 'fails' do
      is_expected.to raise_error Puppet::Error, %r{not supported on Solaris}
    end
  end
end
