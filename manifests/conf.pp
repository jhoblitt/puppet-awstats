# == Define: awstats::conf
#
define awstats::conf(
  $template = undef,
  $options  = {},
) {
  validate_string($template)
  validate_hash($options)

  include ::awstats::params
  require ::awstats

  $real_template = $template ? {
    undef   => $::awstats::params::default_template,
    default => $template,
  }

  # results from testing with awstats-7.0-3.el6.noarch
  #
  # these directives are mandatory:
  # * LogFile
  # * LogFormat
  # * SiteDomain
  #
  # if DirData is not set, data will get dumped in the cgi-bin dir.  eg
  # /usr/share/awstats/wwwroot/cgi-bin/<foo>.txt
  #
  # if HostAliases is not set, a warning is generated. eg.  Warning:
  # HostAliases parameter is not defined, awstats choose "<fqdn> localhost
  # 127.0.0.1"
  #
  # despite what the docs at http://awstats.org/docs/awstats_config.html say,
  # all other configuration directives appear to be optional

  $default_options = {
    'LogFile'      => '/var/log/httpd/access_log',
    'LogFormat'    => '1',
    'DirData'      => '/var/lib/awstats',
    'SiteDomain'   => $::fqdn,
    'HostAliases'  => "localhost 127.0.0.1 ${::hostname}",
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
