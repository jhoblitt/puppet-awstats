# == Class: awstats::conf
#
define awstats::conf(
  $template = undef,
  $options  = {},
) {
  validate_string($template)
  validate_hash($options)

  include ::awstats::params

  $real_template = $template ? {
    undef   => $::awstats::params::default_template,
    default => $template,
  }

  $default_options = {
    'LogFile'      => '/var/log/httpd/access_log',
    'LogType'      => 'W',
    'LogFormat'    => '1',
    'LogSeparator' => ' ',
    'DirData'      => '/var/lib/awstats',
    'SiteDomain'   => $::fqdn,
    'HostAliases'  => $::hostname,
  }

  $conf_options = merge($default_options, $options)

  file { "${::awstats::params::config_dir_path}/awstats.${title}.conf":
    ensure  => 'file',
    owner   => 'root',
    group   => 'root',
    mode    => '0644',
    content => template($real_template),
  }
}
