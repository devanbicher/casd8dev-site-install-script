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

#sudo mysql -e "CREATE DATABASE $dbname"
#sudo mysql -e "CREATE USER '$dbname'@'%' IDENTIFIED BY '$pass'"
#sudo mysql -e "GRANT USAGE ON * . * TO '$dbname'@'%' IDENTIFIED BY '$pass' WITH MAX_QUERIES_PER_HOUR 0 MAX_CONNECTIONS_PER_HOUR 0 MAX_UPDATES_PER_HOUR 0 MAX_USER_CONNECTIONS 0"
#sudo mysql -e "GRANT ALL PRIVILEGES ON $dbname . * TO '$dbname'@'%'"


#drush site-install standard --account-pass=$(pwgen 16) --account-name='casd9devadmin' --account-mail=incasweb@lehigh.edu --site-mail=incasweb@lehigh.edu --sites-subdir=d9-dlb213.cas.lehigh.edu --db-url=mysql://d9_dlb213_test_setup:Phipoon4xaem@localhost/d9_dlb213_test_setup
