#!/bin/bash

if [ -z "$SUDO_COMMAND" ]
then
  echo -e "Only root can run this script.\nRelaunching script with sudo.\n"
  sudo -E $0 $*
  exit
fi

# {{{ gitUpdateTomcatConfFiles()

gitUpdateTomcatConfFiles()
{
  echo "Updating fedora_tomcat_conf_sample files"
  if [ -d fedora_tomcat_conf_sample ]; then
    cd fedora_tomcat_conf_sample
    git fetch origin
    git reset --hard origin/master
    cd ..
  else
    git clone git@github.com:discoverygarden/fedora_tomcat_conf_sample.git
  fi
}

# }}}
#{{{ logrotateSetup()

logrotateSetup()
{
  echo "$2"
  cp $1 /etc/logrotate.d/
  chmod 644 /etc/logrotate.d/$1
}

# }}}
# {{{ frontendSetup()

frontendSetup()
{
# Copy files for Drupal server
if [ -d "/etc/apache2" ] || [ -d "/etc/httpd" ];then
  logrotateSetup drupal_syslog "Copying log configs for a frontend server"
  logrotateSetup islandora_log

  # Create islandora log dir
  if [ ! -d /var/log/islandora ]; then
    mkdir /var/log/islandora
    chmod 0777 /var/log/islandora
  fi
else
  echo "Apache does not seem to be installed"
  echo "Skipping log configs for frontend servers"
fi
}

# }}}
# {{{ tomcatSetup()

tomcatSetup()
{
  echo ""
  cp $tomcatConfDir/logging.properties  $tomcatConfDir/logging.backup
  cp logging.properties $tomcatConfDir/logging.properties
  cp $tomcatConfDir/server.xml $tomcatConfDir/server.backup
  cp fedora_tomcat_conf_sample/server.xml $tomcatConfDir/server.xml

  if [ "$2" = "fedoraToo" ]; then
    echo "Blazegraph has been installed on same server as Fedora"
    echo "Please enter desired port numbers that will be used in server.xml"
    read -p "Enter HTTP connector port: [8081]" httpc
    read -p "Enter HTTPS connector port: [8444]" httpsc
    read -p "Enter AJP connector port: [8010]" ajpc
    read -p "Enter shutdown port: [8006]" shutdownc

    sed -i "s|8005|$shutdownc|g" $tomcatConfDir/server.xml
    sed -i "s|8009|$ajpc|g" $tomcatConfDir/server.xml
    sed -i "s|8080|$httpc|g" $tomcatConfDir/server.xml
    sed -i "s|8443|$httpsc|g" $tomcatConfDir/server.xml

  fi
}

# }}}
# {{{ backendSetup()

backendSetup()
{
  gitUpdateTomcatConfFiles

  if [ -d /usr/local/fedora/tomcat/conf ]; then
    logrotateSetup islandora_logrotate "Copying log configs for a backend server with Fedora"
    tomcatConfDir=/usr/local/fedora/tomcat/conf
    cp /usr/local/fedora/tomcat/webapps/fedoragsearch/WEB-INF/classes/log4j.xml /usr/local/fedora/tomcat/webapps/fedoragsearch/WEB-INF/classes/log4j.backup
    cp log4j.xml /usr/local/fedora/tomcat/webapps/fedoragsearch/WEB-INF/classes/log4j.xml
    cp fedora_tomcat_conf_sample/server.xml /usr/local/fedora/tomcat/conf/server.xml
    cp /usr/local/fedora/tomcat/webapps/adore-djatoka/WEB-INF/classes/log4j.properties /usr/local/fedora/tomcat/webapps/adore-djatoka/WEB-INF/classes/log4j.backup
    cp log4j.properties /usr/local/fedora/tomcat/webapps/adore-djatoka/WEB-INF/classes/log4j.properties
    tomcatSetup
    echo "Fedora server.xml has been updated with logging changes."
    echo "Require manual service restart of Fedora..."

    if [ -d /usr/share/tomcat-blzg/conf ]; then
      logrotateSetup blazegraph_log "Copying log configs for a backend server with Blazegraph"
      tomcatConfDir=/usr/share/tomcat-blzg/conf
      tomcatSetup fedoraToo
      echo "Blazegraph server.xml has been updated with logging changes."
      echo "Require manual service restart of Blazegraph..."
    elif [ -d /usr/local/tomcat-blzg/conf ]; then
      logrotateSetup blazegraph_log "Copying log configs for a backend server with Blazegraph"
      sed -i "s|/usr/share/tomcat-blzg|/usr/local/tomcat-blzg|g" /etc/logrotate.d/blazegraph_log
      tomcatConfDir=/usr/local/tomcat-blzg/conf
      tomcatSetup fedoraToo
      echo "Blazegraph server.xml has been updated with logging changes."
      echo "Require manual service restart of Blazegraph..."
    fi
  else
    if [ -d /usr/share/tomcat-blzg/conf ]; then
      logrotateSetup blazegraph_log "Copying log configs for a backend server with Blazegraph"
      tomcatConfDir=/usr/share/tomcat-blzg/conf
      tomcatSetup
      echo "Blazegraph server.xml has been updated with logging changes."
      echo "Require manual service restart of Blazegraph..."
    elif [ -d /usr/share/tomcat/conf]; then
      logrotateSetup generic_tomcat_log "Copying log configs for a backend server with generic Tomcat"
      tomcatConfDir=/usr/share/tomcat/conf
      tomcatSetup
      echo "Tomcat server.xml has been updated with logging changes."
      echo "Require manual service restart of Tomcat..."
    else
      echo "Tomcat in non-standard location or was installed from binaries"
      echo "Not placing any backend logging configuration."
      echo "Manual review required..."
      exit 2
    fi
  fi
}

# }}}

frontendSetup
backendSetup
