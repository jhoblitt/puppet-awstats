# frozen_string_literal: true

require 'spec_helper_acceptance'

describe 'awstats class' do
  hostname = fact('hostname')

  include_examples 'the example', 'awstats.pp'

  %w[
    awstats
    perl-Geo-IP
    perl-URI
  ].each do |package_name|
    describe package(package_name) do
      it { is_expected.to be_installed }
    end
  end

  describe file('/etc/awstats') do
    it { is_expected.to be_directory }
    it { is_expected.to be_owned_by 'root' }
    it { is_expected.to be_grouped_into 'root' }
    it { is_expected.to be_mode 755 }
  end

  describe file('/etc/awstats/awstats.defaults.example.org.conf') do
    it { is_expected.to be_file }
    it { is_expected.to be_owned_by 'root' }
    it { is_expected.to be_grouped_into 'root' }
    it { is_expected.to be_mode 644 }

    its(:content) do
      is_expected.to match <<~EOS
        DirData="/var/lib/awstats"
        HostAliases="localhost 127.0.0.1 #{hostname}"
        LogFile="/var/log/httpd/access_log"
        LogFormat=1
        SiteDomain="defaults.example.org"
      EOS
    end
  end

  describe file('/etc/awstats/awstats.tweaked.example.org.conf') do
    it { is_expected.to be_file }
    it { is_expected.to be_owned_by 'root' }
    it { is_expected.to be_grouped_into 'root' }
    it { is_expected.to be_mode 644 }

    its(:content) do
      is_expected.to match <<~EOS
        AllowFullYearView=2
        DNSLookup=1
        DirData="/var/lib/awstats"
        HostAliases="localhost 127.0.0.1 #{hostname}"
        LoadPlugin="decodeutfkeys"
        LoadPlugin="geoip"
        LogFile="/var/log/httpd/access_log"
        LogFormat=1
        SiteDomain="tweaked.example.org"
      EOS
    end
  end
end
