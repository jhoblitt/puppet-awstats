# == Class: awstats
#
class awstats(
  $config_dir_purge = false,
  $enable_plugins   = [],
) inherits ::awstats::params {
  validate_bool($config_dir_purge)
  validate_array($enable_plugins)

  package{ $::awstats::params::package_name: } ->
  file { $::awstats::params::config_dir_path:
    ensure  => 'directory',
    owner   => 'root',
    group   => 'root',
    mode    => '0755',
    recurse => true,
    purge   => $config_dir_purge,
  }

  if size($enable_plugins) > 0 {
    $load = prefix(downcase($enable_plugins), '::awstats::plugin::')
    include $load
  }
}
