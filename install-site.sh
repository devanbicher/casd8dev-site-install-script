#!/bin/bash

set -e

site=$1
short=$2
themeflag=$3

if [ "$site" = "" ]
then
    echo "No site url provided
Usage: $0 <full site url> <shortname> [--notheme]"
exit 1
fi

if [ "$short" = "" ]
then
    echo "No name provided
Usage: $0 <full site url> <shortname> [--notheme]"
exit 1
fi

#set theme variable true first
theme=1

# put an initial if of '--' if you add other command line options
if [ "$themeflag" != "" ]
then
    if [ "$themeflag" = "--notheme" ]
    then
        theme=0
    else
    echo "you specified an option but didn't use --nodev, you put:  $themeflag 
        did you mean to you '--notheme'?
        exiting"
    exit 1
    fi
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

mkdir themes
chgrp drupaladm themes
chmod g+w themes
chmod g+s themes

#db info file
echo "<?php \$dbname = '$dbname';
\$dbuser = '$dbname';
\$dbpass = '$pass';
\$dbhost = 'localhost';
?>" > dbinfo.php

#baseurl file
echo "<?php  \$baseurl = 'https://$site'; ?>" > baseurl.php

echo "<?php  \$public_files_dir = 'files/$short'; ?> " > publicfiles.php

#hashsalt
echo "<?php  \$hash_salt = '$(pwgen -s 75)'; ?>" > hash_salt.php

#files directory
mkdir $rootpath/files/$short
mkdir $rootpath/files/$short/private
mkdir $rootpath/files/$short/config
#don't need this for now. we changed how we do to the footer social media menu. 
#cp -r ~/install-site/startup-images/ $rootpath/files/$short/

chgrp -R drupalweb $rootpath/files/$short
chmod -R g+w $rootpath/files/$short
chmod -R g+s $rootpath/files/$short

ln -s $rootpath/files/$short files

#echo "drush -l $site site-install standard --account-name=""$dbname""_cas_admin --account-mail=incasweb@lehigh.edu --site-mail=incasweb@lehigh.edu --account-pass=$(pwgen 16) --site-name='"$dbprefix" "$short" Site (casd8devserver)'"
#--db-url=mysql://$dbname:$pass@localhost/$dbname

echo "installing the site with our install profile"

sitealias="@""$dbprefix""."$short

drush -l $site site-install cas_department --account-name="$dbname"_cas_admin --account-mail=incasweb@lehigh.edu --site-mail=incasweb@lehigh.edu --account-pass=$(pwgen 16) --site-name=" $dbprefix $short Site (casd8devserver)"

echo "clearing caches"
drush $sitealias -y cr 
echo "running an updb"
drush $sitealias -y updb
echo "doing a config export"
drush $sitealias -y config:export

now=$(date +'%H%M-%m%d%y')
#now copy the config folder to another folder to 'save ' initial config
cd $rootpath/files/$short
cp -r config/ config-initial-$now
#initialize git repo in config folder, add files, commit
cd config
git init
git add ./*.yml
git commit -am "initial commit after site installation, config same as cas department profile"


if [ "$theme" -eq "1" ]
then
    echo "setting up git stuff for the theme.  This is only for development 
    "
    cd $rootpath/sites/$short/themes
    git clone ssh://git@gogs.cc.lehigh.edu:2222/cas-web-team/cas_base.git
    cd cas_base

    echo " 
    running yarn stuff. this might take a bit
    "
    yarn 
    yarn build

    drush $sitealias -y cr 
else
    echo "not pulling and setting up the theme. hope that wasn't a mistake"
fi


echo "REMINDER:  Services.yml has 2 debug settings turned on.  Settings.php has debug settings turned on at the bottom (uncomment last 3 lines 
                when (if?) you split the default profile into a dev version, or implement config split, remove those lines from debug settings."


echo "
NEW UPDATES TO MAKE:
yay! nothing for now.
"