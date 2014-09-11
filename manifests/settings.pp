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

  $m2 = "$home/.m2"
  $created_file = "/var/db/.puppet_exec_installed_maven_settings"

  if $local_repository == undef {
    $local_repo = "$m2/repository"
  }
  else
  {
    $local_repo = $local_repository
  }

  file { "$m2":
    ensure => "directory",
    owner  => "${::luser}",
    mode  => "700"
  }

  file { "/tmp/create_mvn_security":
    ensure => "present",
    source => "puppet:///modules/maven/create_settings_security.sh",
    mode   => "0755",
    backup => "false"
  }

  file { "$m2/settings.xml":
    ensure    => "present",
    content   => template("maven/settings.xml.erb"),
    replace   => "no",
  }

  file { "/tmp/mvn_passwd":
    ensure => "present",
    source => "puppet:///modules/maven/append_mvn_encryptedpass.sh",
    mode => "0755",
    backup => "false",
  }

  # only execute the command if the created file is absent
  exec { "create_maven_settings":
    command => "/tmp/create_mvn_security \
                && test -e $password_file \
                && /tmp/mvn_passwd $password_file \
                && touch $created_file",
    user    => root,
    cwd     => "/tmp",
    creates => $created_file,
    require => [File["$m2"], File["/tmp/create_mvn_security"], File["$m2/settings.xml"], File["/tmp/mvn_passwd"]],
  }

}
