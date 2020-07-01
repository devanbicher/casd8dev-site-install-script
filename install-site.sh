#!/bin/bash

#dbname=$1

site=$1
short=$2

#if the user doesn't specify the doc root use casdev
docroot=$3

# flags
# -d8
# -d9

if [ "$site" = "" ]
then
    echo "No name provided
Usage: $0 <full site url> <shortname> <docroot>"
exit 1
fi

if [ "$short" = "" ]
then
    echo "No name provided
Usage: $0 <full site url> <shortname> <docroot>"
exit 1
fi

if [ "$docroot" = "" -o "$docroot" = "casdev"]
then
    echo "no docroot provided (or you chose to use casdev, the default)
Usage: $0 <full site url> <shortname> <docroot(d9, d8, or casdev[default])>

Using default of /var/www/casdev/web/
"
    rootpath= /var/www/casdev/web
    cd $rootpath/sites/

    dbprefix="casdev"
    
    
    #else d9
    #else d8
    #else exit
    
    
fi

year=$(date +'%y')

pass=$(pwgen -s 16)

dbname="$dbprefix""_$short""_$year"

sudo mysql -e "CREATE DATABASE $dbname"
sudo mysql -e "CREATE USER '$dbname'@'%' IDENTIFIED BY '$pass'"
sudo mysql -e "GRANT USAGE ON * . * TO '$dbname'@'%' IDENTIFIED BY '$pass' WITH MAX_QUERIES_PER_HOUR 0 MAX_CONNECTIONS_PER_HOUR 0 MAX_UPDATES_PER_HOUR 0 MAX_USER_CONNECTIONS 0"
sudo mysql -e "GRANT ALL PRIVILEGES ON $dbname . * TO '$dbname'@'%'"

echo "dbname:  $dbname
user: $dbname 
pass: $pass 

mysql://$dbname:$pass@localhost/$dbname
" >> dbinfo/$dbname.txt

#copy folder and stuff



#add site to sites.php
echo "\$sites['$site'] = '$short';
" >> sites.php

#setup alias
echo "
$short:
  root: $rootpath
  uri: http://$site
" >> $rootpath/../drush/sites/'$dbprefix'.sites.yml

drush cc drush

drush @'$dbprefix'.$short site-install standard --account-name='$dbname'_cas_admin --account-mail=incasweb@lehigh.edu --site-mail=incasweb@lehigh.edu --account-pass=$(pwgen 16) --site-name='CAS Dev Server $short Site'
#--db-url=mysql://$dbname:$pass@localhost/$dbname



#to-do:
#
# add line to sites.php
# add an alias
# setup base_url
# setup config_sync_directory

#copy the site folder from somewhere
