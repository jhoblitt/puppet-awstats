# == Class: awstats
#
class awstats(
  $config_dir_purge = false,
  $enable_plugins   = [],
  $cron_purge       = false,
) inherits ::awstats::params {
  validate_bool($config_dir_purge)
  validate_array($enable_plugins)
  validate_bool($cron_purge)

  package{ $::awstats::params::package_name: } ->
  file { $::awstats::params::config_dir_path:
    ensure  => 'directory',
    owner   => 'root',
    group   => 'root',
    mode    => '0755',
    recurse => true,
    purge   => $config_dir_purge,
  }

  if str2bool($cron_purge) {
    file {'/etc/cron.hourly/00awstats':
      ensure => 'absent'
    }
  } else {
    file {'/etc/cron.hourly/00awstats':
      ensure => file,
      source => 'puppet:///modules/awstats/00awstats',
      owner  => 'root',
      group  => 'root',
      mode   => '0755',
    }
  }

  if size($enable_plugins) > 0 {
    $load = prefix(downcase($enable_plugins), '::awstats::plugin::')
    include $load
  }
}
