# == Class: awstats
#
# simple template
#
# === Examples
#
# include awstats
#
class awstats(
  $config_dir_purge = false,
) inherits ::awstats::params {
  validate_bool($config_dir_purge)

  package{ $::awstats::params::package_name: } ->
  file { $::awstats::params::config_dir_path:
    ensure  => 'directory',
    recurse => true,
    purge   => $config_dir_purge,
  }
}
