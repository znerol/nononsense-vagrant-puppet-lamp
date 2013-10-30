No-nonsense vagrant+puppet LAMP setup
=====================================

Apache
------
* Mount data to /data using NFS (user:vagrant, group:vagrant)
* Add user www-data to vagrant group
  -> no fussing around with permissions
* Set apache document root to /data/htdocs
* Set log-location to /data/log/apache2
* No virtual-host support
  -> no messing around with hosts-file
* Run apache on port 8080, also add forwarding
  -> http://localhost:8080/
* PHP info in http://localhost:8080/info.php
* APC tool in http://localhost:8080/apc.php
* Tip: Follow the apache error-log in the host system:
  tail -f log/apache2/error.log

PHP
---
* Use up-to-date PHP packages from http://www.dotdeb.org/
* Packages: apc, gd, mysql, xsl
* Customize INI using config/php-overrides.ini

MySQL
-----
* No root password.
* phpmyadmin in http://localhost:8080/phpmyadmin
* Tip: Link your dump files into data/mysql-restore and trigger the
  provisioning. The basename of the dump-file will be used as the target
  database name. Keep extensions (like .bz2 and .gz), they will be used to
  determine which decompression tool to use. Example:

    ln -s /full/path/to/my/dump.sql.gz data/mysql-restore/mydb-42.gz
    vagrant provision

  The whole mysql database `mydb_42` will be replaced with the contents of the
  dump file. After successful completion, the dump file will be removed!
