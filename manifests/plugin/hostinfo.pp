class awstats::plugin::hostinfo {
  if $caller_module_name != $module_name {
    fail("Use of private class ${name} by ${caller_module_name}")
  }

  # el6 does not appear to package Net::XWhois
  ensure_resource('perl::module', 'Net::XWhois', { use_package => false })
}
