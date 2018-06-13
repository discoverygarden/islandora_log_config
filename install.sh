#!/bin/bash

if [ -z "$SUDO_COMMAND" ]
then
  echo -e "Only root can run this script.\nRelaunching script with sudo.\n"
  sudo -E $0 $*
  exit
fi

# Copy files for Drupal server
if [ -d "/etc/apache2" ] || [ -d "/etc/httpd" ];then
  echo "Copying log configs for a frontend server"
  cp drupal_syslog islandora_log /etc/logrotate.d/
  chmod 644 /etc/logrotate.d/drupal_syslog /etc/logrotate.d/islandora_log

  # Create islandora log dir
  if [ ! -d /var/log/islandora ]; then
    mkdir /var/log/islandora
    chmod 0777 /var/log/islandora
  fi
else
  echo "Apache does not seem to be installed"
  echo "Skipping log configs for frontend servers"
fi

gitUpdateTomcatConfFiles()
{
  echo "Updating fedora_tomcat_conf_sample files"
  if [ -d fedora_tomcat_conf_sample ]; then
    cd fedora_tomcat_conf_sample
    git pull --force
    cd ..
  else
    git clone git@github.com:discoverygarden/fedora_tomcat_conf_sample.git
  fi
}

# Copy files for backend server
if [ -d /usr/local/fedora/tomcat/conf ]; then
  gitUpdateTomcatConfFiles
  echo "Copying log configs for a backend server with Fedora"
  cp islandora_logrotate /etc/logrotate.d/
  chmod 644 /etc/logrotate.d/islandora_logrotate
  cp /usr/local/fedora/tomcat/webapps/fedoragsearch/WEB-INF/classes/log4j.xml /usr/local/fedora/tomcat/webapps/fedoragsearch/WEB-INF/classes/log4j.backup
  cp log4j.xml /usr/local/fedora/tomcat/webapps/fedoragsearch/WEB-INF/classes/log4j.xml
  cp /usr/local/fedora/tomcat/conf/logging.properties  /usr/local/fedora/tomcat/conf/logging.backup
  cp logging.properties /usr/local/fedora/tomcat/conf/logging.properties
  cp /usr/local/fedora/tomcat/conf/server.xml /usr/local/fedora/tomcat/conf/server.backup
  cp fedora_tomcat_conf_sample/server.xml /usr/local/fedora/tomcat/conf/server.xml
  cp /usr/local/fedora/tomcat/webapps/adore-djatoka/WEB-INF/classes/log4j.properties /usr/local/fedora/tomcat/webapps/adore-djatoka/WEB-INF/classes/log4j.backup
  cp log4j.properties /usr/local/fedora/tomcat/webapps/adore-djatoka/WEB-INF/classes/log4j.properties
  if [ -d /usr/share/tomcat-blzg/conf ] || [ -d /usr/local/tomcat-blzg ]; then
    echo "Blazegraph has been installed on same server as Fedora"
    echo "Please enter desired port numbers that will be used in server.xml"
    read -p "Enter HTTP connector port: [8081]" httpc
    read -p "Enter HTTPS connector port: [8444]" httpsc
    read -p "Enter AJP connector port: [8010]" ajpc
    read -p "Enter shutdown port: [8006]" shutdownc

    echo "Copying log configs for a backend server with Blazegraph"
    cp blazegraph_log /etc/logrotate.d/
    chmod 644 /etc/logrotate.d/blazegraph_log
    cp /usr/share/tomcat-blzg/conf/logging.properties /usr/share/tomcat-blzg/conf/logging.backup
    cp logging.properties /usr/share/tomcat-blzg/conf/logging.properties
    cp /usr/share/tomcat-blzg/conf/server.xml /usr/share/tomcat-blzg/conf/server.backup
    cp fedora_tomcat_conf_sample/server.xml /usr/share/tomcat-blzg/conf/server.xml
    sed -i "s|8005|$shutdownc|g" /usr/share/tomcat-blzg/conf/server.xml
    sed -i "s|8009|$ajpc|g" /usr/share/tomcat-blzg/conf/server.xml
    sed -i "s|8080|$httpc|g" /usr/share/tomcat-blzg/conf/server.xml
    sed -i "s|8443|$httpsc|g" /usr/share/tomcat-blzg/conf/server.xml
    echo "Blazegraph server.xml has been updated with logging changes."
    echo "Require manual service restart of Blazegraph..."
  fi
  echo "Fedora server.xml has been updated with logging changes."
  echo "Require manual service restart of Fedora..."
else
  gitUpdateTomcatConfFiles
  if [ -d /usr/share/tomcat-blzg/conf ]; then
    echo "Copying log configs for a backend server with Blazegraph"
    cp blazegraph_log /etc/logrotate.d/
    chmod 644 /etc/logrotate.d/blazegraph_log
    cp /usr/share/tomcat-blzg/conf/logging.properties /usr/share/tomcat-blzg/conf/logging.backup
    cp logging.properties /usr/share/tomcat-blzg/conf/logging.properties
    cp /usr/share/tomcat-blzg/conf/server.xml /usr/share/tomcat-blzg/conf/server.backup
    cp fedora_tomcat_conf_sample/server.xml /usr/share/tomcat-blzg/conf/server.xml
    echo "Blazegraph server.xml has been updated with logging changes."
    echo "Require manual service restart of Blazegraph..."
  elif [ -d /usr/share/tomcat/conf]; then
    echo "Copying log configs for a backend server with generic Tomcat"
    cp generic_tomcat_log /etc/logrotate.d/
    chmod 644 /etc/logrotate.d/generic_tomcat_log
    cp /usr/share/tomcat/conf/logging.properties /usr/share/tomcat/conf/logging.backup
    cp logging.properties /usr/share/tomcat/conf/logging.properties
    cp /usr/share/tomcat/conf/server.xml /usr/share/tomcat/conf/server.backup
    cp fedora_tomcat_conf_sample/server.xml /usr/share/tomcat/conf/server.xml
    echo "Tomcat server.xml has been updated with logging changes."
    echo "Require manual service restart of Tomcat..."
  else
    echo "Tomcat in non-standard location or was installed from binaries"
    echo "Not placing any backend logging configuration."
    echo "Manual review required..."
    exit 2
  fi
fi
