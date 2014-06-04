# Create a maven settings file
class maven::settings ( $home = undef,
  $local_repository = undef,
  $password_file = undef,
  $local_profile_name = 'default',
  $mirrors  = [],
  $repos    = [],
  $properties = [],
  $servers  = [],
  $proxies  = [],) {

  exec {"passfile_exists":
    command => 'true',
    onlyif  => "test -e ${password_file}",
  }
  exec {"test -e ${password_file}":}

  file { "${home}/.m2":
    ensure => "directory",
    owner  => "${::luser}",
    mode  => '700'
  }

  if $local_repository == undef {
  	$local_repo = "${home}/.m2/repository"
  }

  file {'/tmp/create_mvn_security':
    ensure => 'present',
    source => 'puppet:///modules/maven/create_settings_security.sh',
    mode   => '0755',
    backup => 'false'
  }

  exec {"settings-security":
    command =>  '/tmp/create_mvn_security',
    path    => ['/bin','/usr/bin','/opt/boxen/homebrew/bin'],
    unless  => 'test -e ~/.m2/settings-security.xml',
    require => File['/tmp/create_mvn_security']
  }

  file { "${home}/.m2/settings.xml":
    ensure    => 'present',
    content   => template('maven/settings.xml.erb'),
    replace   => 'no',
  }

  file { '/tmp/mvn_passwd':
    ensure => 'present',
    source => 'puppet:///modules/maven/append_mvn_encryptedpass.sh',
    mode => '0755',
    backup => 'false',
    require => [Exec["test -e ${password_file}"],Exec["settings-security"]]
  }

  # clean up empty passwords
  exec { 'add_passwords':
    command => "/tmp/mvn_passwd ${password_file}",
    path => ['/bin','/usr/bin','/opt/boxen/homebrew/bin'],
    require => [File['/tmp/mvn_passwd'],File["${home}/.m2/settings.xml"],Exec["test -e ${password_file}"]]
  }
}
