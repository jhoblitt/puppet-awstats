require 'spec_helper'

describe 'awstats', :type => :class do

  context 'supported operating systems' do
    on_supported_os.each do |os, facts|
      context "on #{os}" do
        let(:facts) do
          facts
        end

        context 'default params' do
          it { should contain_package('awstats') }

          it do
            should contain_file('/etc/awstats').with(
              :ensure  => 'directory',
              :owner   => 'root',
              :group   => 'root',
              :mode    => '0755',
              :recurse => true,
              :purge   => false
            )
          end
          it { should contain_file('/etc/awstats').that_requires('Package[awstats]') }
        end # default params

        context 'config_dir_purge =>' do
          context 'true' do
            let(:params) {{ :config_dir_purge => true }}

            it { should contain_package('awstats') }

            it do
              should contain_file('/etc/awstats').with(
                :ensure  => 'directory',
                :owner   => 'root',
                :group   => 'root',
                :mode    => '0755',
                :recurse => true,
                :purge   => true
              )
            end
            it { should contain_file('/etc/awstats').that_requires('Package[awstats]') }
          end

          context 'false' do
            let(:params) {{ :config_dir_purge => false }}

            it { should contain_package('awstats') }

            it do
              should contain_file('/etc/awstats').with(
                :ensure  => 'directory',
                :owner   => 'root',
                :group   => 'root',
                :mode    => '0755',
                :recurse => true,
                :purge   => false
              )
            end
            it { should contain_file('/etc/awstats').that_requires('Package[awstats]') }
          end

          context '42' do
            let(:params) {{ :config_dir_purge => 42 }}

            it 'should fail' do
              should raise_error(Puppet::Error, /is not a boolean/)
            end
          end
        end # config_dir_purge =>

        context 'enable_plugins =>' do
          context "[ 'decodeutfkeys' ]" do
            let(:params) {{ :enable_plugins => [ 'decodeutfkeys' ] }}

            case facts[:osfamily]
            when 'Debian'
              it { should contain_package('liburi-perl') }
            when 'RedHat'
              it { should contain_package('perl-URI') }
            end

            it do
              should contain_class('awstats::plugin::decodeutfkeys').
                that_comes_before('Anchor[awstats::end]')
            end
          end

          context "[ 'geoip' ]" do
            let(:params) {{ :enable_plugins => [ 'geoip' ] }}

            case facts[:osfamily]
            when 'Debian'
              it { should contain_package('libgeo-ip-perl') }
            when 'RedHat'
              it { should contain_package('perl-Geo-IP') }
            end

            it do
              should contain_class('awstats::plugin::geoip').
                that_comes_before('Anchor[awstats::end]')
            end
          end

          # check case insensitivity and multiple enable_plugins
          context "[ 'DECODEUTFKEYS', 'GEOIP' ]" do
            let(:params) {{ :enable_plugins => [ 'DECODEUTFKEYS', 'GEOIP' ] }}

            case facts[:osfamily]
            when 'Debian'
              it { should contain_package('liburi-perl') }
              it { should contain_package('libgeo-ip-perl') }
            when 'RedHat'
              it { should contain_package('perl-URI') }
              it { should contain_package('perl-Geo-IP') }
            end
          end

          context '42' do
            let(:params) {{ :enable_plugins => 42 }}

            it 'should fail' do
              should raise_error(Puppet::Error, /is not an Array/)
            end
          end
        end # enable_plugins =>
      end
    end

    context 'el5.x' do
      let(:facts) do
        {
          :osfamily                  => 'RedHat',
          :operatingsystem           => 'RedHat',
          :operatingsystemmajrelease => '5',
        }
      end

      it 'should fail' do
        should raise_error(Puppet::Error, /not supported on operatingsystemmajrelease 5/)
      end
    end # el5.x

    context 'el8.x' do
      let(:facts) do
        {
          :osfamily                  => 'RedHat',
          :operatingsystem           => 'RedHat',
          :operatingsystemmajrelease => '8',
        }
      end

      it 'should fail' do
        should raise_error(Puppet::Error, /not supported on operatingsystemmajrelease 8/)
      end
    end # el5.x
  end # on osfamily RedHat

  context 'on osfamily Solaris' do
    let(:facts) {{ :osfamily => 'Solaris', :operatingsystem => 'Solaris' }}

    it 'should fail' do
      should raise_error Puppet::Error, /not supported on Solaris/
    end
  end # on osfamily Solaris
end
