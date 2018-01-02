#!/bin/bash

if [ -z "$SUDO_COMMAND" ]
then
  echo -e "Only root can run this script.\nRelaunching script with sudo.\n"
  sudo $0 $*
  exit
fi

if [ -z $CATALINA_HOME ];then
  echo "Install failed"
  echo '$CATALINA_HOME is undefined'
else
  cp islandora_logrotate drupal_syslog /etc/logrotate.d/
  chmod 644 /etc/logrotate.d/islandora_logrotate /etc/logrotate.d/drupal_syslog
  cp log4j.xml          $CATALINA_HOME/webapps/fedoragsearch/WEB-INF/classes/log4j.xml
  cp logging.properties $CATALINA_HOME/conf/logging.properties
  cp log4j.properties   $CATALINA_HOME/webapps/adore-djatoka/WEB-INF/classes/log4j.properties
fi
