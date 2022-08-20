#
# @summary Install and configure awstats
#
# @param owner
#   awstats role user.
#
# @param group
#   awstats role group.
#
# @param config_dir_path
#   Path of the awstats configuration directory.
#
# @param packages
#   List of packages to install.
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
class awstats (
  String $owner,
  String $group,
  Stdlib::Absolutepath $config_dir_path,
  Optional[Array[String[1]]] $packages = undef,
  Boolean $config_dir_purge            = false,
  Array[String] $enable_plugins        = [],
) {
  unless ($packages) {
    fail("Module ${module_name} is not supported on ${fact('os.family')}")
  }

  package { $packages: }
  -> file { $config_dir_path:
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
