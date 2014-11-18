require 'spec_helper'

describe 'awstats', :type => :class do

  context 'for osfamily RedHat' do
    let(:facts) do
      {
        :osfamily                  => 'RedHat',
        :operatingsystem           => 'RedHat',
        :operatingsystemmajrelease => 6,
      }
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

        it { should contain_package('perl-URI') }
      end

      context "[ 'geoip' ]" do
        let(:params) {{ :enable_plugins => [ 'geoip' ] }}

        it { should contain_package('perl-Geo-IP') }
      end

      # check case insensitivity and multiple enable_plugins
      context "[ 'DECODEUTFKEYS', 'GEOIP' ]" do
        let(:params) {{ :enable_plugins => [ 'DECODEUTFKEYS', 'GEOIP' ] }}

        it { should contain_package('perl-URI') }
        it { should contain_package('perl-Geo-IP') }
      end

      context '42' do
        let(:params) {{ :enable_plugins => 42 }}

        it 'should fail' do
          should raise_error(Puppet::Error, /is not an Array/)
        end
      end
    end # enable_plugins =>
  
    context 'el5.x' do
      before { facts[:operatingsystemmajrelease] = '5' }

      it 'should fail' do
        should raise_error(Puppet::Error, /not supported on operatingsystemmajrelease 5/)
      end
    end # el5.x

    context 'el7.x' do
      before { facts[:operatingsystemmajrelease] = '7' }

      it 'should fail' do
        should raise_error(Puppet::Error, /not supported on operatingsystemmajrelease 7/)
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
