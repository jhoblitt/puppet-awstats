Puppet awstats Module
=====================

[![Build Status](https://travis-ci.org/jhoblitt/puppet-awstats.png)](https://travis-ci.org/jhoblitt/puppet-awstats)

#### Table of Contents

1. [Overview](#overview)
2. [Description](#description)
3. [Usage](#usage)
    * [Examples](#examples)
    * [Classes](#classes)
    * [Defines](#defines)
4. [Limitations](#limitations)
    * [Tested Platforms](#tested-platforms)
5. [Versioning](#versioning)
6. [Support](#support)
7. [Contributing](#contributing)
8. [See Also](#see-also)


Overview
--------

Manages the AWStats HTTP/FTP/SMTP log analyzer


Description
-----------

"AWStats is a free powerful and featureful tool that generates advanced web,
streaming, ftp or mail server statistics, graphically." --
[www.awstats.org](http://www.awstats.org/)

This is a puppet module for the installation and configuration of the
[AWStats]() package.  It offers comprehensive configuration file generation
and limited support for the enabling AWStats plugins.

Currently, this module relies on the package to enable periodic log processing.
The `EPEL6`package installs an hourly crontab that runs as root.  This is
sub-optimal for security purposes as AWStats is a complex script but
understandable as historically logs have had `root` ownership.  A future
release of this module may provide for AWStats to be invoked as a non-`root`
user.


Usage
-----

### Examples

#### Install `awstats` and configure `apache`

Example of configuring Apache for the AWStats CGI interface using the
[`puppetlabs/apache`](https://forge.puppetlabs.com/puppetlabs/apache) module.

```puppet
$loadplugin     = ['decodeutfkeys', 'geoip GEOIP_STANDARD /usr/share/GeoIP/GeoIP.dat']
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
```

#### Local `apache` log

```puppet
# apache log
awstats::conf { 'www.example.org':
  options => {
    'SiteDomain'        => 'www.example.org',
    'HostAliases'       => 'localhost 127.0.0.1 example.org',
    'LogFile'           => 'sudo -iu loguser ssh loguser@example.org sudo cat /var/log/httpd/access_log |',
    'AllowFullYearView' => 3,
    'DNSLookup'         => 1,
    'SkipHosts'         => $internal_hosts,
    'LoadPlugin'        => $loadplugin,
  },
}
```

#### Local 'apache' log

Defaults to processing `/var/log/httpd/access_log`.

```puppet
# apache log
awstats::conf { 'www.example.org': }
```

Which is equivalent to:

```puppet
# apache log
awstats::conf { 'www.example.org':
  options => { # defaults
    'LogFile'      => '/var/log/httpd/access_log',
    'LogFormat'    => '1',
    'DirData'      => '/var/lib/awstats',
    'SiteDomain'   => $::fqdn,
    'HostAliases'  => "localhost 127.0.0.1 ${::hostname}",
  },
}
```

#### Remote `apache` log via `ssh`

```puppet
# apache log
awstats::conf { 'www.example.org':
  options => {
    'SiteDomain'        => 'www.example.org',
    'HostAliases'       => 'localhost 127.0.0.1 example.org',
    'LogFile'           => 'sudo -iu loguser ssh loguser@example.org sudo cat /var/log/httpd/access_log |',
    'AllowFullYearView' => 3,
    'DNSLookup'         => 1,
    'SkipHosts'         => $internal_hosts,
    'LoadPlugin'        => $loadplugin,
  },
}
```

#### Remote `vsftp` log via `ssh`

```puppet
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
    'LoadPlugin'        => $loadplugin,
  },
}
```

#### Remote `pureftpd` log via `ssh`


```puppet
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
    'LoadPlugin'        => $loadplugin,
  },
}
```

### Classes

#### `awstats`

```puppet
# defaults
class { '::awstats':
  config_dir_purge => false,
  enable_plugins   => [],
}
```

##### `config_dir_purge`

`Boolean` Default to: `false`

If set to `true`, unmanaged files in the configuration directory path,
typically `/etc/awstats/` are purged.

##### `enable_plugins`

`Array` Defaults to: `[]`

A case insensitive list of awstats plugins to enable "support" for by
installing required dependencies. The supported plugins are:

* decodeutfkeys
* geoip

### Defines

#### `awstats::conf`

```puppet
# defaults
awstats::conf { '<title>':
  template => undef,
  options  => {},
}
```

##### `template`

`String` Defaults to `undef`

The path to the puppet ERB template to use to generate the configuration file.
A value of `undef` is equivalent to `${module_name}/awstats.conf.erb`.

##### `options`

`Hash` Defaults to `{}`

A hash of awstats configuration file options.  The case of keys is preserved
and no validation of what is or isn't a valid awstats directive is performed.
The options hash is merged with these default values, which were determined to
be the minimum set of required parameters via trial and error with EPEL6
`awstats-7.0-3.el6.noarch` package.  Please see the comments in
[`conf.pp`](manifests/conf.pp) for further details.

```puppet
  $default_options = {
    'LogFile'      => '/var/log/httpd/access_log',
    'LogFormat'    => '1',
    'DirData'      => '/var/lib/awstats',
    'SiteDomain'   => $::fqdn,
    'HostAliases'  => "localhost 127.0.0.1 ${::hostname}",
  }
```

If a hash value is an array, multiple configuration file options with the same
key name will be created. Eg.

```puppet
  options => {
    'LoadPlugin' => ['foo', 'bar'],
  }
```

Would result in the following options in the configuration file.  Note that the
order is sorted.

```
LoadPlugin="bar"
LoadPlugin="foo"
```

Limitations
-----------

This module has been developed around the awstats version 7 package from
`EPEL6`.  A bit unfortunately, that package runs `awstats.pl` from `cron` as the
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
* [`puppetlabs/apache`](https://forge.puppetlabs.com/puppetlabs/apache)
