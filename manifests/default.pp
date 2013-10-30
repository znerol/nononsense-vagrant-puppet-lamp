## GENERIC

# Run apt-get update before installing packages
exec { "apt-update":
    command => "/usr/bin/apt-get update"
}
Exec["apt-update"] -> Package <| |>


## DOT DEB SOURCES
exec { "install-dotdeb-key":
  command => "/usr/bin/wget -O- http://www.dotdeb.org/dotdeb.gpg | /usr/bin/apt-key add -",
  notify => Exec["apt-update"]
}

file { "/etc/apt/sources.list.d/dotdeb.list":
  ensure => present,
  source => "/vagrant/config/dotdeb.list",
  notify => Exec["install-dotdeb-key"]
}
File["/etc/apt/sources.list.d/dotdeb.list"] -> Package <| |>


## LAMP PACKAGES
package {[
  "apache2",
  "libapache2-mod-php5",
  "mysql-client",
  "mysql-server",
  "php-apc",
  "php5",
  "php5-gd",
  "php5-mysql",
  "php5-xsl",
  "phpmyadmin"]:
  ensure => latest
}


## APACHE
service { "apache2":
  ensure => running,
  hasstatus => true,
  hasrestart => true,
  require => Package["apache2"],
}
user { "www-data":
  ensure => present,
  groups => ["vagrant"],
}
file { "/etc/apache2/sites-enabled/100-localhost-8080.conf":
  ensure => present,
  source => "/vagrant/config/apache-localhost-8080.conf",
  notify => Service["apache2"],
  require => [
    File["/data/cgi-bin"],
    File["/data/htdocs"],
    File["/data/log/apache2"],
  ],
}
file { [
    "/data/cgi-bin",
    "/data/htdocs",
    "/data/log",
    "/data/log/apache2"]:
  ensure => directory,
  mode => 0775,
}
file { "/etc/apache2/mods-enabled/php5.load":
  ensure => link,
  target => "/etc/apache2/mods-available/php5.load",
  require => Package["apache2"],
  notify => Service["apache2"],
}
file { "/etc/apache2/mods-enabled/php5.conf":
  ensure => link,
  target => "/etc/apache2/mods-available/php5.conf",
  require => Package["apache2"],
  notify => Service["apache2"],
}
file { "/etc/apache2/mods-enabled/rewrite.load":
  ensure => link,
  target => "/etc/apache2/mods-available/rewrite.load",
  require => Package["apache2"],
  notify => Service["apache2"],
}


## PHP
file { "/etc/php5/conf.d/30-overrides.ini":
  ensure => present,
  source => "/vagrant/config/php-overrides.ini",
  require => Package["php5"],
  notify => Service["apache2"],
}


## PHPMYADMIN
file { "/etc/apache2/conf.d/phpmyadmin.conf":
  ensure => link,
  target => "/etc/phpmyadmin/apache.conf",
  require => Package["apache2"],
  notify => Service["apache2"],
}
file { "/var/lib/phpmyadmin/config.inc.php":
  ensure => present,
  source => "/vagrant/config/phpmyadmin-overrides.inc.php",
  require => Package["phpmyadmin"],
  notify => Service["apache2"],
}
