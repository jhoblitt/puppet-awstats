#
# @summary Install and configure awstats
#
# @param config_dir_purge
#   Default to: `false`
#
#   If set to `true`, unmanaged files in the configuration directory path,
#   typically `/etc/awstats/` are purged.
#
# @param enable_plugins
#   Defaults to: `[]`
#
#   A case insensitive list of awstats plugins to enable "support" for by
#   installing required dependencies. The supported plugins are:
#
#   * decodeutfkeys
#   * geoip
#
# @param owner
#   awstats user
#
# @param group
#   awstats group
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
