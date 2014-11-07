require 'spec_helper'

describe 'awstats', :type => :class do

  describe 'for osfamily RedHat' do
    let(:facts) {{ :osfamily => 'RedHat', :operatingsystem => 'RedHat' }}

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

  describe 'for osfamily Solaris' do
    let(:facts) {{ :osfamily => 'Solaris', :operatingsystem => 'Solaris' }}

    it 'should fail' do
      expect { should compile }.to raise_error Puppet::Error, /not supported on Solaris/
    end
  end

end
