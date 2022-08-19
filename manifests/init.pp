# == Class: awstats
#
class awstats (
  Boolean $config_dir_purge = false,
  Array $enable_plugins     = [],
  String $owner             = $awstats::params::owner,
  String $group             = $awstats::params::group,
) inherits awstats::params {
  package { $awstats::params::package_name: }
  -> file { $awstats::params::config_dir_path:
    ensure  => 'directory',
    owner   => $owner,
    group   => $group,
    mode    => '0755',
    recurse => true,
    purge   => $config_dir_purge,
  }

  $enable_plugins.each |$plugin| {
    contain "awstats::plugin::${plugin}"
  }
}
