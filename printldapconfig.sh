#!/bin/bash

echo "
go to https://$site/admin/config/development/configuration/single/import

copy the following into the input area after selecting LDAP Server from the dropdown list

langcode: en
status: true
dependencies: {  }
id: nis_lehigh
label: nis.cc.lehigh.edu
type: openldap
address: nis.cc.lehigh.edu
port: 389
timeout: 10
tls: false
followrefs: null
weight: null
bind_method: user
binddn: null
bindpw: null
basedn: 'dc=lehigh,dc=edu'
user_attr: uid
account_name_attr: ''
mail_attr: mail
mail_template: ''
picture_attr: ''
unique_persistent_attr: ''
unique_persistent_attr_binary: false
user_dn_expression: 'uid=%username,%basedn'
testing_drupal_username: ''
testing_drupal_user_dn: ''
grp_unused: false
grp_object_cat: ''
grp_nested: false
grp_user_memb_attr_exists: false
grp_user_memb_attr: ''
grp_memb_attr: ''
grp_memb_attr_match_user_attr: ''
grp_derive_from_dn: '0'
grp_derive_from_dn_attr: ''
grp_test_grp_dn: ''
grp_test_grp_dn_writeable: ''
search_pagination: false
search_page_size: null

Then run the following commands:
drush cset --input-format=yaml ldap_authentication.settings sids '
nis_lehigh: nis_lehigh'

drush cset ldap_authentication.settings authenticationMode '2'

drush ucrt $USER
drush urol administrator $USER

"
