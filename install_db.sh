#!/bin/bash

#this will just create the db, user, password
#then
#spit out the info to a file,
#probably change the file perms to only 700 chown $USER


echo "Remember this only creates the database, user nothing else."

dbname=$1


if [ "$dbname" = "" ]
then
    echo "No name provided
Usage: $0 dbname "
exit 1
fi

pass=$(pwgen -s 16)

sudo mysql -e "CREATE DATABASE $dbname"
sudo mysql -e "CREATE USER '$dbname'@'%' IDENTIFIED BY '$pass'"
sudo mysql -e "GRANT USAGE ON * . * TO '$dbname'@'%' IDENTIFIED BY '$pass' WITH MAX_QUERIES_PER_HOUR 0 MAX_CONNECTIONS_PER_HOUR 0 MAX_UPDATES_PER_HOUR 0 MAX_USER_CONNECTIONS 0"
sudo mysql -e "GRANT ALL PRIVILEGES ON $dbname . * TO '$dbname'@'%'"

echo "dbname:  $dbname
user: $dbname 
pass: $pass 

mysql://$dbname:$pass@localhost/$dbname
" >> dbinfo/$dbname.txt

echo "drush site-install standard --account-name=$dbname_admin --account-mail=incasweb@lehigh.edu --site-mail=incasweb@lehigh.edu --account-pass=$(pwgen 16) --site-name='Drupal8 fresh install' --db-url=mysql://$dbname:$pass@localhost/$dbname --sites-subdir="
