#!/bin/bash

set -e

#need the docroot

#sh <website folder> <dbname> <docroot>

cd /var/www/casdev/web/sites


rm -r $website

cd ../files

rm -r $website


sudo mysql -e "drop database $dbname;"

sudo mysql -e "drop user $dbname;"
