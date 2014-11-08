require 'spec_helper'

describe 'awstats', :type => :class do

  context 'for osfamily RedHat' do
    let(:facts) {{ :osfamily => 'RedHat', :operatingsystem => 'RedHat' }}

    context 'default params' do 
      it { should contain_package('awstats') }

      it do
        should contain_file('/etc/awstats').with(
          :ensure  => 'directory',
          :recurse => 'true',
          :purge   => 'false',
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
            :recurse => 'true',
            :purge   => 'true',
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
            :recurse => 'true',
            :purge   => 'false',
          )
        end
        it { should contain_file('/etc/awstats').that_requires('Package[awstats]') }
      end

      context '42' do
        let(:params) {{ :config_dir_purge => 42 }}

        it 'should fail' do
          expect { should }.to raise_error(Puppet::Error, /is not a boolean/)
        end

      end
    end # config_dir_purge =>
  end # on osfamily RedHat

  context 'on osfamily Solaris' do
    let(:facts) {{ :osfamily => 'Solaris', :operatingsystem => 'Solaris' }}

    it 'should fail' do
      expect { should compile }.to raise_error Puppet::Error, /not supported on Solaris/
    end
  end # on osfamily Solaris
end
