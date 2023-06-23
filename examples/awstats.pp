if fact('os.family') == 'RedHat' {
  class { 'epel': } -> Class['awstats']

  # lint:ignore:case_without_default
  case fact('os.release.major') {
    '8': {
      class { 'yum':
        managed_repos => ['PowerTools'],
        before        => Class['awstats'],
      }
    }
    '9': {
      class { 'yum':
        managed_repos => ['crb'],
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
