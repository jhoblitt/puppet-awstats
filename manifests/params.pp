# == Class: awstats::params
#
# This class should be considered private
#
class awstats::params {
  case $::osfamily {
    'FreeBSD': {
      $package_name     = 'awstats'
      $config_dir_path  = '/usr/local/etc/awstats'
      $default_template = "${module_name}/awstats.conf.erb"
      $owner            = 'root'
      $group            = 'wheel'
    }
    'RedHat': {
      case $::operatingsystemmajrelease {
        '6', '7', '8': {
          $package_name     = 'awstats'
          $config_dir_path  = '/etc/awstats'
          $default_template = "${module_name}/awstats.conf.erb"
          $owner            = 'root'
          $group            = 'root'
        }
        default: {
          fail("Module ${module_name} is not supported on operatingsystemmajrelease ${::operatingsystemmajrelease}") # lint:ignore:80chars
        }
      }
    }
    'Debian': {
      $package_name     = 'awstats'
      $config_dir_path  = '/etc/awstats'
      $default_template = "${module_name}/awstats.conf.erb"
      $owner            = 'root'
      $group            = 'root'
    }
    default: {
      fail("Module ${module_name} is not supported on ${::operatingsystem}")
    }
  }
}
