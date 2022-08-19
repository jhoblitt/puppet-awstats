#
# @api private
#
class awstats::plugin::decodeutfkeys {
  assert_private()

  # the Encode lib is bundled with core perl on el6
  # the epel6 awstats package has a dep on perl-URI so this class is
  # essentially a no-op
  $package_name = $facts['os']['family'] ? {
    'Debian' => 'liburi-perl',
    'RedHat' => 'perl-URI',
  }
  ensure_packages($package_name)
}
