#!/bin/bash

if [ -z "$SUDO_COMMAND" ]
then
  echo -e "Only root can run this script.\nRelaunching script with sudo.\n"
  sudo $0 $*
  exit
fi

# Create islandora log dir
if [ ! -d /var/log/islandora ]; then
  mkdir /var/log/islandora
fi

# Copy files for Drupal server
if [ -d "/etc/apache2" ] || [ -d "/etc/httpd" ];then
  echo "Copying log configs for a frontend server"
  cp drupal_syslog /etc/logrotate.d/
  chmod 644 /etc/logrotate.d/drupal_syslog
else
  echo "Apache does not seem to be installed"
  echo "Skipping log configs for frontend servers"
fi

# Copy files for backend server
if [ -z $CATALINA_HOME ];then
  echo '$CATALINA_HOME is undefined'
  echo "Skipping log configs for backend servers"
else
  echo "Copying log configs for a backend server"
  cp islandora_logrotate /etc/logrotate.d/
  chmod 644 /etc/logrotate.d/islandora_logrotate
  cp log4j.xml          $CATALINA_HOME/webapps/fedoragsearch/WEB-INF/classes/log4j.xml
  cp logging.properties $CATALINA_HOME/conf/logging.properties
  cp log4j.properties   $CATALINA_HOME/webapps/adore-djatoka/WEB-INF/classes/log4j.properties
fi
