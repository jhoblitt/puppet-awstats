#
# @api private
#
class awstats::plugin::decodeutfkeys (
  Array[String[1]] $packages,
) {
  assert_private()
  ensure_packages($packages)
}
