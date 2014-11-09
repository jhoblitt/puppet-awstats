class awstats::plugin::geoip {
  if $caller_module_name != $module_name {
    fail("Use of private class ${name} by ${caller_module_name}")
  }

  require ::perl

  ensure_resource('perl::module', 'Geo::IP', { use_package => true })
}
