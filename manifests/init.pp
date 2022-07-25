# == Class: awstats
#
class awstats(
  Boolean $config_dir_purge = false,
  Array $enable_plugins   = [],
  String $owner = $awstats::params::owner,
  String $group = $awstats::params::group,
) inherits ::awstats::params {
  package{ $::awstats::params::package_name: }
  -> file { $::awstats::params::config_dir_path:
    ensure  => 'directory',
    owner   => $owner,
    group   => $group,
    mode    => '0755',
    recurse => true,
    purge   => $config_dir_purge,
  }

  if size($enable_plugins) > 0 {
    $load = prefix(downcase($enable_plugins), '::awstats::plugin::')
    include $load

    anchor { 'awstats::begin': }
    -> Class[$load]
    -> anchor { 'awstats::end': }
  }
}
