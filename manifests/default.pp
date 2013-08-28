## GENERIC

# Run apt-get update before installing packages
exec { "apt-update":
    command => "/usr/bin/apt-get update"
}

Exec["apt-update"] -> Package <| |>


## GENERIC PACKAGES
package {[
  "augeas-tools",
  "augeas-lenses",
  "libaugeas-ruby"]:
  ensure => latest
}


## LAMP PACKAGES
package {[
  "apache2",
  "libapache2-mod-php5",
  "libapache2-mod-upload-progress",
  "mysql-client",
  "mysql-server",
  "php-apc",
  "php-pear",
  "php5",
  "php5-cli",
  "php5-dev",
  "php5-gd",
  "php5-mysql",
  "php5-sqlite",
  "php5-xdebug",
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
    File["/srv/cgi-bin"],
    File["/srv/htdocs"],
    File["/srv/log/apache2"],
  ],
}
file { [
    "/srv/cgi-bin",
    "/srv/htdocs",
    "/srv/log",
    "/srv/log/apache2"]:
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
