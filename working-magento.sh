#!/bin/bash
echo "##################################################################"
echo
echo "Welcome to magento creating "
echo
echo "##################################################################"
echo
echo "Enter domain name you want to create magento with"
echo "Example : hvs11.hyperx.cloud"
echo
read -p 'Enter domain name: ' domainvar
read -p 'Enter username:unique name ' uservar
read -p 'Enter email id : ' eid
read -p 'Enter Password:not contain username and is strong ' passvar
echo yes | /usr/local/cpanel/scripts/wwwacct $domainvar $uservar $passvar 0 paper_lantern n y n unlimited unlimited 0 0 0 0 y root default unlimited unlimited default $eid 0 en y unlimited
echo "please wait while usre is being creating ...."
echo
echo "user is created"
echo "copying directories......"
cp -arf /home/hvsblogger/public_html/* /home/$uservar/public_html/
rm -rf /home/$uservar/public_html/var/cache/* /home/$uservar/public_html/var/page_cache/* /home/$uservar/public_html/var/generation/*
chown -hR $uservar:$uservar /home/$uservar/public_html/*
chmod +x /home/$uservar/public_html/bin/magento
echo "All file and directories are copied...."
echo "creating database"
id=$(cut -c-8 <<< "$uservar")
echo you db-name is : $id'_magento'
echo you db-user is : $id'_magento'
cpprefix=$(uapi --user="$uservar" Mysql get_restrictions --output=json | sed -e 's/^.*"prefix":"\([^"]*\)".*$/\1/');
rndm='_magento';
password='magentomagento';
db="$cpprefix""$rndm";
uapi --user="$uservar" --output=json Mysql create_database name="$db"
uapi --user="$uservar" --output=json Mysql create_user name="$db" password="$password"
uapi --user="$uservar" Mysql set_privileges_on_database user="$db" database="$db" privileges=ALL%20PRIVILEGES
echo
echo "#########################################################"
echo
echo  db setup completed 
echo
echo "##########################################################"
echo
/home/hvsblogger/public_html/bin/magento config:set system/backup/functionality_enabled 1
echo 
mysqldump -u root hvsblogg_magento > /root/hvsblogg_magento.sql
mysql -u root $db < /root/hvsblogg_magento.sql
echo

# this will change database name and database  username in newuser config
#sudo sed -i 's/enforcing/disabled/g' /etc/selinux/config /etc/selinux/config

sed -i "s/hvsblogg_magento/$db/g" /home/$uservar/public_html/app/etc/env.php /home/$uservar/public_html/app/etc/env.php
#/home/$uservar/public_html/bin/magento setup:store-config:set --base-url="http://$domainvar"
#/home/$uservar/public_html/bin/magento setup:store-config:set --base-url="https://$domainvar"
echo
/home/$uservar/public_html/bin/magento setup:di:compile
echo compiling...........
/home/$uservar/public_html/bin/magento setup:static-content:deploy -f
/home/$uservar/public_html/bin/magento cache:flush
chown -hR $uservar:$uservar /home/$uservar/public_html/*
echo deploying...........
/home/$uservar/public_html/bin/magento setup:store-config:set --base-url="http://$domainvar"
/home/$uservar/public_html/bin/magento setup:store-config:set --base-url-secure="https://$domainvar"
#this will generate auto url for user
#testing -->>  admin=`date +%s | base64 | head -c 8 ; echo`;
#testing -->> /home/$uservar/public_html/bin/magento setup:config:set --backend-frontname $adminuri
echo
admin=`date +%s  | base64 | head -c 8 ; echo`;
( echo y;  echo y;) | /home/$uservar/public_html/bin/magento setup:config:set --backend-frontname 'admin_'$admin
echo
echo Note down your Admin_login_url very carefully
/home/$uservar/public_html/bin/magento info:adminuri

/home/$uservar/public_html/bin/magento cache:flush
echo please wait !!!
echo
echo :: PRE INSTALLATION COMPLETED ::
echo
echo
#########################         #######################################       
#########################  TEST   #######################################
#########################	  #######################################
echo :: POST INSTALLATION ON WORK ::
#
#/home/$uservar/public_html/bin/magento setup:di:compile 
#/home/$uservar/public_html/bin/magento setup:static-content:deploy -f
chown -hR $uservar:$uservar /home/$uservar/public_html/*
#/home/$uservar/public_html/bin/magento setup:store-config:set --base-url="http://$domainvar:80"
#/home/$uservar/public_html/bin/magento setup:store-config:set --base-url-secure="https://$domainvar:443"

chmod -R 755 /home/$uservar/public_html/*
chmod 644 /home/$uservar/public_html/.htaccess

chmod 777 /home/$uservar/public_html/var/*

#
#
#
/home/$uservar/public_html/bin/magento cache:flush > /dev/null
echo
echo " you can visit your website"
