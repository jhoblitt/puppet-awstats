#
# @summary manage awstats config file
#
# ```puppet
# # defaults
# awstats::conf { '<title>':
#   template        => undef,
#   options         => {},
# }
# ```
#
# @param template
#   Defaults to `undef`
#
#   The path to the puppet ERB template to use to generate the configuration
#   file.
#
#   A value of `undef` is equivalent to `${module_name}/awstats.conf.erb`.
#
# @param options
#   Defaults to `{}`
#
#   A hash of awstats configuration file options.  The case of keys is preserved
#   and no validation of what is or isn't a valid awstats directive is performed.
#   The options hash is merged with these default values, which were determined to
#   be the minimum set of required parameters via trial and error with EPEL6
#   `awstats-7.0-3.el6.noarch` package.
#
# ```puppet
#   $default_options = {
#     'LogFile'     => '/var/log/httpd/access_log',
#     'LogFormat'   => '1',
#     'DirData'     => '/var/lib/awstats',
#     'SiteDomain'  => $::fqdn,
#     'HostAliases' => "localhost 127.0.0.1 ${::hostname}"
#   }
# ```
#
#   If a hash value is an array, multiple configuration file options with the
#   same key name will be created. Eg.
#
# ```puppet
#   options         => {
#     'LoadPlugin'  => ['foo', 'bar'],
#   }
# ```
#
#   Would result in the following options in the configuration file.  Note that
#   the order is sorted.
#
# ```
# LoadPlugin="bar"
# LoadPlugin="foo"
# ```
#
define awstats::conf (
  Optional[String] $template = undef,
  Hash $options              = {},
) {
  include awstats::params
  require awstats

  $real_template = $template ? {
    undef   => $awstats::params::default_template,
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
    'SiteDomain'   => $title,
    'HostAliases'  => "localhost 127.0.0.1 ${fact('networking.hostname')}",
  }

  $conf_options = merge($default_options, $options)

  file { "${awstats::params::config_dir_path}/awstats.${title}.conf":
    ensure  => 'file',
    owner   => $awstats::owner,
    group   => $awstats::group,
    mode    => '0644',
    content => template($real_template),
  }
}
