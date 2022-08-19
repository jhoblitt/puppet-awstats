#
# @api private
#
class awstats::plugin::geoip (
  Array[String[1]] $packages,
) {
  assert_private()
  ensure_packages($packages)
}
