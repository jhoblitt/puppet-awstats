require 'spec_helper'

describe 'awstats::conf', :type => :define do
  context 'on osfamily RedHat' do
    let(:facts) do
      {
        :osfamily => 'RedHat',
        :fqdn     => 'foo.example.org',
        :hostname => 'foo',
      }
    end
    let(:title) { 'foo.example.org' }

    context 'default params' do
      it do
        should contain_file('/etc/awstats/awstats.foo.example.org.conf').with(
          :ensure => 'file',
          :owner  => 'root',
          :group  => 'root',
          :mode   => '0644'
        )
      end
      it do
        should contain_file('/etc/awstats/awstats.foo.example.org.conf')\
          .with_content(<<-eos)
DirData="/var/lib/awstats"
HostAliases="foo"
LogFile="/var/log/httpd/access_log"
LogFormat=1
LogSeparator=" "
LogType="W"
SiteDomain="foo.example.org"
eos
      end
    end # default params

    context 'template =>' do
      context 'dne.erb' do
        let(:params) {{ :template => 'dne.erb' }}

        it 'should fail' do
          expect { should }.to raise_error(Puppet::Error, /Could not find template/)
        end
      end # dne.erb

      context '[]' do
        let(:params) {{ :template => [] }}

        it 'should fail' do
          expect { should }.to raise_error(Puppet::Error, /is not a string/)
        end
      end # []
    end # template =>

    context 'options =>' do
      context '<add new keys>' do
        let(:params) {{ :options => { 'foo' => 1, 2 => 'bar' } }}

        it do
          should contain_file('/etc/awstats/awstats.foo.example.org.conf').with(
            :ensure => 'file',
            :owner  => 'root',
            :group  => 'root',
            :mode   => '0644'
          )
        end
        it do
          should contain_file('/etc/awstats/awstats.foo.example.org.conf')\
            .with_content(<<-eos)
2="bar"
DirData="/var/lib/awstats"
HostAliases="foo"
LogFile="/var/log/httpd/access_log"
LogFormat=1
LogSeparator=" "
LogType="W"
SiteDomain="foo.example.org"
foo=1
eos
        end
      end # <add new keys>

      context '<replace existing keys>' do
        let(:params) {{ :options => { 'DirData' => 1, 'LogFormat' => 'bar' } }}

        it do
          should contain_file('/etc/awstats/awstats.foo.example.org.conf').with(
            :ensure => 'file',
            :owner  => 'root',
            :group  => 'root',
            :mode   => '0644'
          )
        end
        it do
          should contain_file('/etc/awstats/awstats.foo.example.org.conf')\
            .with_content(<<-eos)
DirData=1
HostAliases="foo"
LogFile="/var/log/httpd/access_log"
LogFormat="bar"
LogSeparator=" "
LogType="W"
SiteDomain="foo.example.org"
eos
        end
      end # <add new keys>

      context 'foo' do
        let(:params) {{ :options => 'foo' }}

        it 'should fail' do
          expect { should }.to raise_error(Puppet::Error, /is not a Hash/)
        end
      end # foo
    end # options =>
  end # on osfamily RedHat
end
