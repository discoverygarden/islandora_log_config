islandora\_log\_config
===================

Rotates the logs created by Islandora, fedora, activemq,  gsearch and tomcat.

Will need to be modified to include microservices and batch ingest.
The first user who needs this should submit the patch.

General Usage:
Stop Fedora and other Tomcat services e.g. Blazegraph before running. 

Example: 

```
service fedora stop
service blazegraph stop
git clone git@github.com:discoverygarden/islandora_log_config.git
cd islandora_log_config
sudo ./manual_install.sh
```

**File locations default:**

* /etc/logrotate.d/islandora_logrotate
* /etc/logrotate.d/islandora_log
* /etc/logrotate.d/blazegraph_log
* /etc/logrotate.d/drupal_syslog
* /usr/local/fedora/tomcat/webapps/fedoragsearch/WEB-INF/classes/log4j.xml
* /usr/local/fedora/tomcat/conf/logging.properties
* /usr/local/fedora/tomcat/webapps/adore-djatoka/WEB-INF/classes/log4j.properties
* /usr/local/fedora/server/config/logback.xml
* /usr/local/fedora/tomcat/conf/server.xml

