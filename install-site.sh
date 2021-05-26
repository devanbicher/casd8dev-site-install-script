#!/bin/bash

set -e

site=$1
short=$2

#if the user doesn't specify the doc root use casdev
install_profile=$3


if [ "$site" = "" ]
then
    echo "No site url provided
Usage: $0 <full site url> <shortname> <docroot>"
exit 1
fi

if [ "$short" = "" ]
then
    echo "No name provided
Usage: $0 <full site url> <shortname> <docroot>"
exit 1
fi

echo "This script uses the docroot
    /var/www/casdev/web/
use basic-site-install.sh to choose a different docroot
"
rootpath='/var/www/casdev/web'
cd $rootpath/sites/
pwd     
dbprefix='casdev'
    
    
year=$(date +'%y')

pass=$(pwgen -s 16)

dbname="$dbprefix""_$short""_$year"

echo $dbname

sudo mysql -e "CREATE DATABASE $dbname"
sudo mysql -e "CREATE USER '$dbname'@'%' IDENTIFIED BY '$pass'"
sudo mysql -e "GRANT USAGE ON * . * TO '$dbname'@'%' IDENTIFIED BY '$pass' WITH MAX_QUERIES_PER_HOUR 0 MAX_CONNECTIONS_PER_HOUR 0 MAX_UPDATES_PER_HOUR 0 MAX_USER_CONNECTIONS 0"
sudo mysql -e "GRANT ALL PRIVILEGES ON $dbname . * TO '$dbname'@'%'"

echo "don't forget to remove the printed out db/user/pass info after this script is fully working."

echo "dbname:  $dbname
user: $dbname 
pass: $pass 

mysql://$dbname:$pass@localhost/$dbname
" >> ~/install-site/dbinfo/$dbname.txt

#copy folder and stuff

#add site to sites.php
echo "\$sites['$site'] = '$short';
" >> sites.php

#setup alias
echo "
$short:
  root: $rootpath
  uri: http://$site
" >> "$rootpath"/../drush/sites/"$dbprefix".site.yml

drush cc drush

#setup php files for new site
mkdir $short
cp ~/install-site/site-default/* $short/
chgrp -R drupaladm $short
chmod u+w $short
chmod g+w $short
cd $short

#baseurl file
echo "<?php  \$baseurl = 'https://$site'; ?>" > baseurl.php

#files directory
mkdir $rootpath/files/$short
mkdir $rootpath/files/$short/private
mkdir $rootpath/files/$short/config
cp -r ~/install-site/startup-images/ $rootpath/files/$short/

chgrp -R drupalweb $rootpath/files/$short
chmod -R g+w $rootpath/files/$short

ln -s $rootpath/files/$short files

echo "<?php  \$public_files_dir = 'files/$short'; ?> " > publicfiles.php

#hashsalt
echo "<?php  \$hash_salt = '$(pwgen -s 75)'; ?>" > hash_salt.php

#db info file
echo "<?php \$dbname = '$dbname';
\$dbuser = '$dbname';
\$dbpass = '$pass';
\$dbhost = 'localhost';
?>" > dbinfo.php


#echo "drush -l $site site-install standard --account-name=""$dbname""_cas_admin --account-mail=incasweb@lehigh.edu --site-mail=incasweb@lehigh.edu --account-pass=$(pwgen 16) --site-name='"$dbprefix" "$short" Site (casd8devserver)'"
#--db-url=mysql://$dbname:$pass@localhost/$dbname

echo "installing the site with our install profile"

sitealias="@""$dbprefix""."$short

drush -l $site site-install test_profile --account-name="$dbname"_cas_admin --account-mail=incasweb@lehigh.edu --site-mail=incasweb@lehigh.edu --account-pass=$(pwgen 16) --site-name=" $dbprefix $short Site (casd8devserver)"

drush $sitealias -y cr 
drush $sitealias -y updb
drush $sitealias -y config:export

echo "REMINDER:  Services.yml has 2 debug settings turned on.  Settings.php has debug settings turned on at the bottom (uncomment last 3 lines "
