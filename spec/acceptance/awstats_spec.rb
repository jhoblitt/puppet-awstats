require 'spec_helper_acceptance'

describe 'awstats class' do
  describe 'running puppet code' do
    pp = <<-EOS
      if $::osfamily == 'RedHat' {
        class { '::epel': } -> Class['::awstats']
      }

      class { '::awstats':
        config_dir_purge => true,
        enable_plugins   => [ 'DecodeUTFKeys', 'GeoIP', 'HostInfo' ],

      }

      ::awstats::conf { 'defaults.example.org':
        config_dir_purge => true,
      }
    EOS

    it 'applies the manifest twice with no stderr' do
      apply_manifest(pp, :catch_failures => true)
      apply_manifest(pp, :catch_changes => true)
    end
  end


  [
    'awstats',
    'perl-Geo-IP',
    'perl-URI'
  ].each do |package_name|
    describe package(package_name) do
      it { should be_installed }
    end
  end

  describe file('/etc/awstats') do
    it { should be_directory }
    it { should be_owned_by 'root' }
    it { should be_grouped_into 'root' }
    it { should be_mode 755 }
  end

  describe file('/etc/awstats/awstats.defaults.example.org.conf') do
    it { should be_directory }
    it { should be_owned_by 'root' }
    it { should be_grouped_into 'root' }
    it { should be_mode 644 }
    its(:content) do
      should match <<-eos
DirData="/var/lib/awstats"
HostAliases="localhost 127.0.0.1 foo"
LogFile="/var/log/httpd/access_log"
LogFormat=1
SiteDomain="foo.example.org"
      eos
    end
  end
end
