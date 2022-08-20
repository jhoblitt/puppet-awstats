# frozen_string_literal: true

require 'spec_helper'

describe 'awstats::conf', type: :define do
  on_supported_os.each do |os, facts|
    context "on #{os}" do
      let(:facts) do
        facts
      end
      let(:title) { 'foo.example.org' }

      context 'default params' do
        it { is_expected.to contain_awstats__conf('foo.example.org').that_requires('Class[awstats]') }

        it do
          is_expected.to contain_file('/etc/awstats/awstats.foo.example.org.conf').with(
            ensure: 'file',
            owner: 'root',
            group: 'root',
            mode: '0644'
          )
        end

        it do
          is_expected.to contain_file('/etc/awstats/awstats.foo.example.org.conf').\
            with_content(<<~EOS)
              DirData="/var/lib/awstats"
              HostAliases="localhost 127.0.0.1 foo"
              LogFile="/var/log/httpd/access_log"
              LogFormat=1
              SiteDomain="foo.example.org"
            EOS
        end
      end

      context 'template =>' do
        context 'dne.erb' do
          let(:params) { { template: 'dne.erb' } }

          it 'fails' do
            is_expected.to raise_error(Puppet::Error, %r{Could not find template})
          end
        end
      end

      context 'options =>' do
        context '<add new keys>' do
          let(:params) { { options: { 'foo' => 1, '2' => 'bar' } } }

          it { is_expected.to contain_awstats__conf('foo.example.org').that_requires('Class[awstats]') }

          it do
            is_expected.to contain_file('/etc/awstats/awstats.foo.example.org.conf').with(
              ensure: 'file',
              owner: 'root',
              group: 'root',
              mode: '0644'
            )
          end

          it do
            is_expected.to contain_file('/etc/awstats/awstats.foo.example.org.conf').\
              with_content(<<~EOS)
                2="bar"
                DirData="/var/lib/awstats"
                HostAliases="localhost 127.0.0.1 foo"
                LogFile="/var/log/httpd/access_log"
                LogFormat=1
                SiteDomain="foo.example.org"
                foo=1
              EOS
          end
        end

        context '<replace existing keys>' do
          let(:params) { { options: { 'DirData' => 1, 'LogFormat' => 'bar' } } }

          it { is_expected.to contain_awstats__conf('foo.example.org').that_requires('Class[awstats]') }

          it do
            is_expected.to contain_file('/etc/awstats/awstats.foo.example.org.conf').with(
              ensure: 'file',
              owner: 'root',
              group: 'root',
              mode: '0644'
            )
          end

          it do
            is_expected.to contain_file('/etc/awstats/awstats.foo.example.org.conf').\
              with_content(<<~EOS)
                DirData=1
                HostAliases="localhost 127.0.0.1 foo"
                LogFile="/var/log/httpd/access_log"
                LogFormat="bar"
                SiteDomain="foo.example.org"
              EOS
          end
        end

        context '<key value is array>' do
          let(:params) { { options: { 'LoadPlugin' => %w[foo bar] } } }

          it { is_expected.to contain_awstats__conf('foo.example.org').that_requires('Class[awstats]') }

          it do
            is_expected.to contain_file('/etc/awstats/awstats.foo.example.org.conf').with(
              ensure: 'file',
              owner: 'root',
              group: 'root',
              mode: '0644'
            )
          end

          it do
            is_expected.to contain_file('/etc/awstats/awstats.foo.example.org.conf').\
              with_content(<<~EOS)
                DirData="/var/lib/awstats"
                HostAliases="localhost 127.0.0.1 foo"
                LoadPlugin="bar"
                LoadPlugin="foo"
                LogFile="/var/log/httpd/access_log"
                LogFormat=1
                SiteDomain="foo.example.org"
              EOS
          end
        end
      end
    end
  end
end
