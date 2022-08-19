#
# @api private
#
class awstats::plugin::geoip {
  assert_private()

  $package_name = $facts['os']['family'] ? {
    'Debian' => 'libgeo-ip-perl',
    'RedHat' => 'perl-Geo-IP',
  }
  ensure_packages($package_name)
}
