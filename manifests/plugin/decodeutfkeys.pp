# == Class: awstats::plugin::decodeutfkeys
#
# This class should be considered private
#
class awstats::plugin::decodeutfkeys {
  if $caller_module_name != $module_name {
    fail("Use of private class ${name} by ${caller_module_name}")
  }

  # the Encode lib is bundled with core perl on el6
  # the epel6 awstats package has a dep on perl-URI so this class is
  # essentially a no-op
  ensure_packages('perl-URI')
}
