# Create a maven settings file
class maven::settings ( $home = undef,
  $master_password = undef,
  $local_repository = undef,
  $local_profile_name = 'default',
  $mirrors  = [],
  $repos    = [],
  $properties = [],
  $servers  = [],
  $proxies  = [],) {

  file { "${home}/.m2":
    ensure => "directory",
    owner  => "${::luser}",
    mode  => '700'
  }

  if $local_repository == undef {
  	$local_repo = "${home}/.m2/repository"
  }

  if $master_password != undef {
    file { "${home}/.m2/settings-security.xml":
      ensure  => 'present',
      content => template('maven/settings-security.xml.erb'),
      mode    => '0600',
      replace => 'no',
    }
  } else {
  	notify {"No master password defined":}
  }
  notify {"SERVERS ${servers}":}
  notify {"master password is ${master_password}":}

  file { "${home}/.m2/settings.xml":
    ensure    => 'present',
    content   => template('maven/settings.xml.erb'),
  }
}