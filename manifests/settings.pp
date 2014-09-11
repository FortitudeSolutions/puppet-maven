# Create a maven settings file
class maven::settings ( $password_file = undef ) {

  $created_file = "/var/db/.puppet_exec_installed_maven_settings"

  file { "${homedir}/.m2":
    ensure => "directory",
    owner  => "${::luser}",
    mode  => "700",
    cwd   => "${homedir}",
    refreshonly => true
  }

  file { "/tmp/create_mvn_security":
    ensure => "present",
    source => "puppet:///modules/maven/create_settings_security.sh",
    mode   => "0755",
    backup => "false",
    refreshonly => true 
  }

  exec { "settings-security":
    command =>  "/tmp/create_mvn_security",
    require => [File["${homedir}/.m2"], File["/tmp/create_mvn_security"]]
    refreshonly => true
  }

  file { "${homedir}/.m2/settings.xml":
    ensure    => "present",
    content   => template("maven/settings.xml.erb"),
    replace   => "no",
    refreshonly => true
  }

  file { "/tmp/mvn_passwd":
    ensure => "present",
    source => "puppet:///modules/maven/append_mvn_encryptedpass.sh",
    mode => "0755",
    backup => "false",
    refreshonly => true
  }

  exec { "passfile_exists":
    command => "test -e ${password_file}",
    refreshonly => true
  }

  # clean up empty passwords
  exec { "add_passwords":
    command => "/tmp/mvn_passwd ${password_file}",
    require => [Exec["settings-security"], File["${homedir}/.m2/settings.xml"], File["/tmp/mvn_passwd"], Exec["passfile_exists"]]
    refreshonly => true
  }

  # only execute the chain if the created file is absent
  exec { "maven_settings":
    command => "touch $created_file",
    creates => $created_file,
    require => Exec["add_passwords"]
  }

}
