#!/bin/bash

set -e

#sh <website folder> <dbname> <docroot>

website=$1

dbname=$2

cd /var/www/casdev/web/sites


sudo rm -rf $website

cd ../files

sudo rm -rf $website


sudo mysql -e "drop database $dbname;"

sudo mysql -e "drop user $dbname;"
