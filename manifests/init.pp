# == Class: awstats
#
# simple template
#
# === Examples
#
# include awstats
#
class awstats inherits ::awstats::params {

  package{ $::awstats::params::package_name: } ->
  file { $::awstats::params::confd_dir:
    ensure  => 'directory',
    recurse => true,
    purge   => true,
  }
}
