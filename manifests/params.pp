# == Class: hiera::params
#
# This class handles OS-specific configuration of the hiera module.  It
# looks for variables in top scope (probably from an ENC such as Dashboard).  If
# the variable doesn't exist in top scope, it falls back to a hard coded default
# value.
#
# === Authors:
#
# Mike Arnold <mike@razorsedge.org>
#
# === Copyright:
#
# Copyright (C) 2013 Mike Arnold, unless otherwise noted.
#
class hiera::params {
  $confdir          = $::settings::confdir
  $hiera_version    = '3'
  $hiera5_defaults  = {'datadir' => 'data', 'data_hash' => 'yaml_data'}
  $package_ensure   = 'present'
  $package_name     = 'hiera'
  $hierarchy        = []
  if str2bool($::is_pe) {
    $hiera_yaml     = '/etc/puppetlabs/puppet/hiera.yaml'
    $datadir        = '/etc/puppetlabs/puppet/hieradata'
    $owner          = 'root'
    $group          = 'root'
    $eyaml_owner    = 'pe-puppet'
    $eyaml_group    = 'pe-puppet'
    $cmdpath        = ['/opt/puppet/bin', '/usr/bin', '/usr/local/bin']
    $manage_package = false

    if $::pe_version and versioncmp($::pe_version, '3.7.0') >= 0 {
      $provider       = 'pe_puppetserver_gem'
      $master_service = 'pe-puppetserver'
    } else {
      $provider       = 'pe_gem'
      $master_service = 'pe-httpd'
    }
  } else {
    # Configure for AIO packaging.
    if getvar('::pe_server_version') {
      $master_service = 'pe-puppetserver'
      $provider       = 'puppetserver_gem'
    } else {
      # It would probably be better to assume this is puppetserver, but that
      # would be a backwards-incompatible change.
      $master_service = 'puppetmaster'
      $provider       = 'puppet_gem'
    }
    $cmdpath        = ['/opt/puppetlabs/puppet/bin', '/usr/bin', '/usr/local/bin']
    $datadir        = '/etc/puppetlabs/code/environments/%{::environment}/hieradata'
    $manage_package = false
    if getvar('::pe_server_version') {
      $owner = 'root'
      $group = 'root'
    } else {
      $owner = 'puppet'
      $group = 'puppet'
    }
    $hiera_yaml = "${confdir}/hiera.yaml"
  }
}
