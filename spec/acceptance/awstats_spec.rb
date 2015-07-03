require 'spec_helper_acceptance'

describe 'awstats class' do
  fqdn = fact 'fqdn'
  hostname = fact 'hostname'

  describe 'running puppet code' do
    pp = <<-EOS
      if $::osfamily == 'RedHat' {
        class { '::epel': } -> Class['::awstats']
      }

      include ::apache

      apache::vhost { 'awstats.example.org':
        port          => '80',
        docroot       => '/usr/share/awstats/wwwroot',
        serveraliases => ['awstats'],
        aliases => [
          { alias => '/awstatsclasses', path => '/usr/share/awstats/wwwroot/classes/' },
          { alias => '/awstatscss', path => '/usr/share/awstats/wwwroot/css/' },
          { alias => '/awstatsicons', path => '/usr/share/awstats/wwwroot/icon/' },
        ],
        scriptaliases => [
          { alias => '/awstats/', path => '/usr/share/awstats/wwwroot/cgi-bin/' },
        ],
        directories   => [{
          path     => '/usr/share/awstats/wwwroot',
          provider => 'directory',
          options  => 'None',
        }],
        setenv        => ['PERL5LIB /usr/share/awstats/lib:/usr/share/awstats/plugins'],
      }

      class { '::awstats':
        config_dir_purge => true,
        enable_plugins   => [ 'DecodeUTFKeys', 'GeoIP' ],
      }

      # this ordering is needed for both the docroot path and so that the
      # awstats package provided apache configuration snippet is purged on the
      # first run
      Class['::awstats'] -> Class['::apache']

      awstats::conf { 'defaults.example.org': }

      awstats::conf { 'tweaked.example.org':
        options => {
          'AllowFullYearView' => 2,
          'DNSLookup'         => 1,
          'LoadPlugin'        => ['decodeutfkeys', 'geoip'],
          'SiteDomain'        => 'tweaked.example.org',
        },
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
    it { should be_file }
    it { should be_owned_by 'root' }
    it { should be_grouped_into 'root' }
    it { should be_mode 644 }
    its(:content) do
      should match <<-eos
DirData="/var/lib/awstats"
HostAliases="localhost 127.0.0.1 #{hostname}"
LogFile="/var/log/httpd/access_log"
LogFormat=1
SiteDomain="#{fqdn}"
      eos
    end
  end

  describe file('/etc/awstats/awstats.tweaked.example.org.conf') do
    it { should be_file }
    it { should be_owned_by 'root' }
    it { should be_grouped_into 'root' }
    it { should be_mode 644 }
    its(:content) do
      should match <<-eos
AllowFullYearView=2
DNSLookup=1
DirData="/var/lib/awstats"
HostAliases="localhost 127.0.0.1 #{hostname}"
LoadPlugin="decodeutfkeys"
LoadPlugin="geoip"
LogFile="/var/log/httpd/access_log"
LogFormat=1
SiteDomain="tweaked.example.org"
      eos
    end
  end
end
