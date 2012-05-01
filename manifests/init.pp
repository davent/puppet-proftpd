# proFTPd Module
class proftpd ( $source = 'proftpd',
  $quota_file = '',
  $quota_engine = 'Off',
  $use_ipv6 = 'Off',
  $default_root = '~',
  $user = 'proftpd',
  $group = 'nogroup',
  $file_umask = '022',
  $dir_umask = '022',
  $auth_file = 'ftpd.passwd',
  $create_home = 'Off' ) {

  package { 'proftpd-basic' : ensure => present }
  motd::register{'proftpd':}

  file{ '/etc/proftpd/proftpd.conf':
    owner   => root,
    group   => root,
    mode    => '0444',
    content => template("proftpd/${source}.erb"),
    require => Package['proftpd-basic'],
  }

  file{ '/etc/proftpd/ftpd.passwd':
    owner   => root,
    group   => root,
    mode    => '0444',
    source  => [ "puppet:///modules/proftpd/${::hostname}-ftpd.passwd", "puppet:///modules/proftpd/ftpd.passwd" ],
    require => Package['proftpd-basic'],
  }

  service{ 'proftpd':
    ensure      => running,
    hasrestart  => true,
    require     => [Package['proftpd-basic'],File['/etc/proftpd/proftpd.conf']],
    subscribe   => File['/etc/proftpd/proftpd.conf', '/etc/proftpd/ftpd.passwd'],
  }

  if ( $quota_file ) {
		
    file{ '/etc/proftpd/ftpquota.limittab':
      owner   => root,
      group   => root,
      mode    => '0444',
      source  => [ "puppet:///modules/proftpd/${quota_file}-ftpquota.limittab" ],
      require => Package['proftpd-basic'],
      notify  => Service['proftpd'],
    }
  }
}

