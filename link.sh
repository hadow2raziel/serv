#!/bin/bash

Help()
{
   # Display Help
   available_offers=$(ls -m /var/www/offers)
   echo -e "Run script with -o offer_name flag and enter an offer name."
   echo -e "Available offer names: $available_offers"
   echo -e "Usage example: link.sh -o ps"
   echo
   echo -e "Script create domain and subdomain automaticaly"
   echo 
   echo -e "When nano open index.php file - insert PHP code by pressing \e[1;33m[shift+insert]\e[0m"
   echo -e "then press: \e[1;33m[ctrl+x]\e[0m for exit {nano}, \e[1;33m[y]\e[0m to save file, \e[1;33m[enter]\e[0m to confirm"
   echo -e "On the last steps enter profile and offer name to get link with utm"
   echo
   echo -e "You can get PHP code from cloacking service"
   echo
}
LinkCreator()
{
	echo -e "\e[1;33mSelected offer: '$offer'\e[0m"
	subdomain=$(tr -dc a-z </dev/urandom | head -c 10; echo)
	echo $subdomain
	domain='appconstructionkit.com'
	echo $domain
	certbot certonly --apache -n -d $subdomain.$domain
	echo "<IfModule mod_ssl.c>
	<VirtualHost *:443>
		ServerAdmin webmaster@localhost
		DocumentRoot /var/www/$subdomain

		ErrorLog ${APACHE_LOG_DIR}/error.log
		CustomLog ${APACHE_LOG_DIR}/access.log combined

		ServerName $subdomain.$domain

		Include /etc/letsencrypt/options-ssl-apache.conf
		SSLCertificateFile /etc/letsencrypt/live/$subdomain.$domain/fullchain.pem
		SSLCertificateKeyFile /etc/letsencrypt/live/$subdomain.$domain/privkey.pem
	</VirtualHost>
</IfModule>" | tee -a /etc/apache2/sites-available/000-default-le-ssl.conf
	cp -r /home/offers/server-main/$offer /var/www/$subdomain
	certbot certonly --force-renew --apache -n -d $subdomain.$domain
	echo "// Link for cloaking: $subdomain.$domain" | tee -a /var/www/$subdomain/index.php
	nano /var/www/$subdomain/index.php
	echo -n "Enter profile name: "
	read profilename
	printf '%s\n' "Your link: https://$subdomain.$domain/?utm_source=$profilename&utm_medium=$offer&utm_term={keyword}"
}

if [ "$*" == "" ]; then
    >&2 echo "No arguments founded. Run script with -h flag for help"
    exit 1
fi


while getopts ":ho:" option; do
   case $option in
      h) # display Help
        Help
        exit;;
	  o) # Offer select
        offer=${OPTARG}
		LinkCreator
		exit;;
     \?) # Invalid option
         echo "Error: Invalid option"
         exit;;
   esac
done

