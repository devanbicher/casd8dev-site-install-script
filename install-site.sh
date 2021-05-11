#!/bin/bash

set -e

site=$1
short=$2

#if the user doesn't specify the doc root use casdev
docroot=$3
theme=$4

# flags
# -d8
# -d9

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

if [ "$docroot" = "" ] || [ "$docroot" = "casdev"]
then
    echo "no docroot provided (or you chose to use casdev, the default)
Usage: $0 <full site url> <shortname> <docroot(drupal9, drupal8, emulsify, or casdev[default])>

Using default of /var/www/casdev/web/
"
    rootpath='/var/www/casdev/web'
    cd $rootpath/sites/

    pwd
    
    dbprefix='casdev'
    
    
    #else d8
elif [ "$docroot" = "drupal8" ] || [ "$docroot" = "drupal9" ] || [ "$docroot" = "emulsify" ]
then
    echo "your docroot choice has been $docroot, the path will be 
   /var/www/$docroot/web/

  NOTE:  Please remember that you will need to adjust your computer's host file for a website in this docroot, or contact keith to get a redirect
  NOTE: if you use the emulsify doc root, you will need to update apache to have that site work with that docroot
"

    rootpath='/var/www/'"$docroot"'/web'
    cd $rootpath/sites/

    pwd
    
    dbprefix="$docroot"
else
    echo "you have made an incorrect selection for the docroot option, useage is:
    Usage: $0 <full site url> <shortname> <docroot(d9, d8, or casdev[default])>
    please make a correct choice, or don't supply a third option and try again
    exiting.
"
exit 1
fi

if [ "$theme" = "" ]
then
    echo "NO THEME SELECTED, this site will NOT have a theme selected, you will manually need to choose the theme. "
    
fi
    
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

cp -r ~/install-site/site-default $short
chgrp -R drupaladm $short
cd $short

#baseurl file
echo "<?php  \$baseurl = 'https://$site'; ?>" > baseurl.php

#files directory
mkdir $rootpath/files/$short
mkdir $rootpath/files/$short/private
mkdir $rootpath/files/$short/config

chmod o+w -R $rootpath/files/$short

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


echo "drush -l $site site-install standard --account-name=""$dbname""_cas_admin --account-mail=incasweb@lehigh.edu --site-mail=incasweb@lehigh.edu --account-pass=$(pwgen 16) --site-name='"$dbprefix" "$short" Site (casd8devserver)'"
#--db-url=mysql://$dbname:$pass@localhost/$dbname

drush -l $site site-install standard --account-name="$dbname"_cas_admin --account-mail=incasweb@lehigh.edu --site-mail=incasweb@lehigh.edu --account-pass=$(pwgen 16) --site-name=" $dbprefix $short Site (casd8devserver)"

sitealias="@""$dbprefix""."$short

echo "enabling modules... "
while read mod; do
    drush $sitealias -y pm-enable "$mod"
done </home/dlb213/install-site/modules.txt 

drush $sitealias -y cim --partial --source=global_config/ldap/nis_lehigh/

echo "Still to do in this script:
    - send an email to the user with the info
    For theme enabling
    --  drush config-set system.theme default THEME_NAME
    Eventually:
    - move the site config, modules, ldap, etc to an install profile
    "

echo "
do these 2 if the import below doesn't work
drush $sitealias -y cset --input-format=yaml ldap_authentication.settings sids '
nis_lehigh: nis_lehigh'
drush $sitealias -y cset ldap_authentication.settings authenticationMode '2'
"
drush $sitealias -y cim --partial --source=global_config/ldap/

drush $sitealias ucrt dlb213
drush $sitealias ucrt taw219
drush $sitealias urol administrator dlb213
drush $sitealias urol administrator taw219

drush uli --name="$USER"

echo "REMINDER:  Services.yml has 2 debug settings turned on.  Settings.php has debug settings turned on at the bottom (uncomment last 3 lines)"
