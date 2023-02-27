WEBROOT=/var/www
HTTPBASE=${WEBROOT}/drupal7
APACHEUSER=www-data
FEDORAUSER=fedora

#Nothing past this point should have to change.
PWD=$(pwd)

RAND=$((RANDOM%10000))

DATE=`date +%Y-%m-%d-%H-%M-%S`

HOSTNAME=`hostname`
USER=`whoami`

yellow='\033[0;33m'
green='\033[0;32m'
red='\033[0;31m'
NC='\033[0m'