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
