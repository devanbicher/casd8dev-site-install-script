#!/bin/bash

set -e

#sh <website folder> <dbname> <docroot>

website=$1

dbname=$2

cd /var/www/casdev/web/sites


sudo rm -r $website

cd ../files

sudo rm -r $website


sudo mysql -e "drop database $dbname;"

sudo mysql -e "drop user $dbname;"
