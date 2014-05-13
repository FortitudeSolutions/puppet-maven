# Install Maven
class maven {
  package { 'maven':
    ensure => 'present',
  }
}
