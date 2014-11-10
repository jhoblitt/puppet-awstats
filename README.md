Puppet awstats Module
=====================

[![Build Status](https://travis-ci.org/jhoblitt/puppet-awstats.png)](https://travis-ci.org/jhoblitt/puppet-awstats)

#### Table of Contents

1. [Overview](#overview)
2. [Description](#description)
3. [Usage](#usage)
    * [Examples](#examples)
    * [Classes](#classes))
    * [Defines](#defines)
4. [Limitations](#limitations)
    * [Tested Platforms](#tested-platforms)
5. [Versioning](#versioning)
6. [Support](#support)
7. [Contributing](#contributing)
8. [See Also](#see-also)


Overview
--------

Manages the Awstats log processor package


Description
-----------

"AWStats is a free powerful and featureful tool that generates advanced web,
streaming, ftp or mail server statistics, graphically." --
[www.awstats.org](http://www.awstats.org/)

This module provides for the install of the awstats package, the dependencies
required by some of the bundled "plugins", and configuration of logfiles to be
processed.

Usage
-----

### Examples

```puppet
$plugins        = ['decodeutfkeys', 'geoip GEOIP_STANDARD /usr/share/GeoIP/GeoIP.dat']
$internal_hosts = 'REGEX[^192\.168\.] REGEX[^172\.16\.] REGEX[^10\.]'

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
    order    => 'Allow,Deny',
    allow    => 'from all',
    #deny    => 'from all',
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

# apache log
awstats::conf { 'www.example.org':
  options => {
    'SiteDomain'        => 'www.example.org',
    'HostAliases'       => 'localhost 127.0.0.1 example.org',
    'LogFile'           => 'sudo -iu loguser ssh loguser@example.org sudo cat /var/log/httpd/access_log |',
    'AllowFullYearView' => 3,
    'DNSLookup'         => 1,
    'SkipHosts'         => $internal_hosts,
    'LoadPlugin'        => $plugins,
  },
}

# vsftp log
awstats::conf { 'ftp.example.org':
  options => {
    'SiteDomain'        => 'ftp.example.org',
    'HostAliases'       => 'localhost 127.0.0.1 example.org',
    'LogFile'           => 'sudo -iu loguser ssh loguser@example.org sudo cat /var/log/vsftpd.log |',
    'LogFormat'         => '%time3 %other %host %bytesd %url %other %other %method %other %logname %other %code %other %other',
    'LogSeparator'      => '\s',
    'LogType'           => 'F',
    'AllowFullYearView' => 3,
    'DNSLookup'         => 1,
    'SkipHosts'         => $internal_hosts,
    'LoadPlugin'        => $plugins,
  },
}

# pureftp log
awstats::conf { 'ftp.example.org':
  options => {
    'SiteDomain'        => 'ftp.example.org',
    'HostAliases'       => 'localhost 127.0.0.1 example.org',
    'LogFile'           => 'sudo -iu loguser ssh loguser@example.org sudo cat /var/log/pureftpdstats.log |',
    'LogFormat'         => '%host %other %logname %time1 %methodurlnoprot %code %bytesd',
    'LogSeparator'      => '\s',
    'LogType'           => 'F',
    'AllowFullYearView' => 3,
    'DNSLookup'         => 1,
    'SkipHosts'         => $internal_hosts,
    'LoadPlugin'        => $plugins,
  },
}
```

### Classes

#### `awstats`

### Defines

#### `awstats::conf`


Limitations
-----------

This module has been develoepd around the awstats version 7 package from
`EPEL6`.  A bit unfortunately, that package runs `awstats.pl` from cron as the
root.  Rather than fighting the package, that decision has been left in place
but may be revised in a future version of this module.

### Tested Platforms

* el6


Versioning
----------

This module is versioned according to the [Semantic Versioning
2.0.0](http://semver.org/spec/v2.0.0.html) specification.


Support
-------

Please log tickets and issues at
[github](https://github.com/jhoblitt/puppet-awstats/issues)


Contributing
------------

1. Fork it on github
2. Make a local clone of your fork
3. Create a topic branch.  Eg, `feature/mousetrap`
4. Make/commit changes
    * Commit messages should be in [imperative tense](http://git-scm.com/book/ch5-2.html)
    * Check that linter warnings or errors are not introduced - `bundle exec rake lint`
    * Check that `Rspec-puppet` unit tests are not broken and coverage is added for new
      features - `bundle exec rake spec`
    * Documentation of API/features is updated as appropriate in the README
    * If present, `beaker` acceptance tests should be run and potentially
      updated - `bundle exec rake beaker`
5. When the feature is complete, rebase / squash the branch history as
   necessary to remove "fix typo", "oops", "whitespace" and other trivial commits
6. Push the topic branch to github
7. Open a Pull Request (PR) from the *topic branch* onto parent repo's `master` branch


See Also
--------

* [www.awstats.org](http://www.awstats.org/)
