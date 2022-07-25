# == Class: awstats::params
#
# This class should be considered private
#
class awstats::params {
  case fact('os.family') {
    'FreeBSD': {
      $package_name     = 'awstats'
      $config_dir_path  = '/usr/local/etc/awstats'
      $default_template = "${module_name}/awstats.conf.erb"
      $owner            = 'root'
      $group            = 'wheel'
    }
    'RedHat': {
      case fact('os.release.major') {
        '6', '7': {
          $package_name     = 'awstats'
          $config_dir_path  = '/etc/awstats'
          $default_template = "${module_name}/awstats.conf.erb"
          $owner            = 'root'
          $group            = 'root'
        }
        default: {
          fail("Module ${module_name} is not supported on operatingsystemmajrelease ${fact('os.release.major')}") # lint:ignore:80chars
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
      fail("Module ${module_name} is not supported on ${fact('os.family')}")
    }
  }
}
