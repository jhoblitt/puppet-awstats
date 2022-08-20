if fact('os.family') == 'RedHat' {
  class { 'epel': } -> Class['awstats']

  # lint:ignore:case_without_default
  case fact('os.release.major') {
    '8': {
      class { 'yum':
        managed_repos => ['PowerTools'],
        repos         => {
          'PowerTools' => {
            'enabled'    => true,
            'descr'      => 'CentOS-$releasever - PowerTools',
            'baseurl'    => 'https://vault.centos.org/$contentdir/$releasever/PowerTools/$basearch/os/',
            'mirrorlist' => absent,
            'gpgcheck'   => true,
            'gpgkey'     => 'file:///etc/pki/rpm-gpg/RPM-GPG-KEY-centosofficial',
            'target'     => '/etc/yum.repos.d/CentOS-Linux-PowerTools.repo',
          },
        },
        before        => Class['awstats'],
      }
    }
    '9': {
      class { 'yum':
        managed_repos => ['crb'],
        repos         => {
          'crb' => {
            'enabled'         => true,
            'descr'           => 'CentOS Stream $releasever - Code Ready Builder',
            'metalink'        => 'https://mirrors.centos.org/metalink?repo=centos-crb-$stream&arch=$basearch&protocol=https,http',
            'metadata_expire' => '6h',
            'gpgcheck'        => true,
            'gpgkey'          => 'file:///etc/pki/rpm-gpg/RPM-GPG-KEY-centosofficial',
            'target'          => '/etc/yum.repos.d/centos.repo',
          },
        },
        before        => Class['awstats'],
      }
    }
  }
  # lint:endignore
}

include apache

apache::vhost { 'awstats.example.org':
  port          => 80,
  docroot       => '/usr/share/awstats/wwwroot',
  serveraliases => ['awstats'],
  aliases       => [
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

class { 'awstats':
  config_dir_purge => true,
  enable_plugins   => ['DecodeUTFKeys', 'GeoIP'],
}

# this ordering is needed for both the docroot path and so that the
# awstats package provided apache configuration snippet is purged on the
# first run
Class['awstats'] -> Class['apache']

awstats::conf { 'defaults.example.org': }

awstats::conf { 'tweaked.example.org':
  options => {
    'AllowFullYearView' => 2,
    'DNSLookup'         => 1,
    'LoadPlugin'        => ['decodeutfkeys', 'geoip'],
    'SiteDomain'        => 'tweaked.example.org',
  },
}
