#!/bin/bash -e

# Load Variables
export $(cat /usr/local/bin/init.cfg | grep -v ^# | xargs)
echo $NOIP_USER
echo $NOIP_PASSWORD
echo $CERTBOT_USER
echo $CERTBOT_DOMAIN
echo $NGINX_UWSGI_PASS

# Setup No-IP
/usr/local/bin/noip2 -C -u $NOIP_USER -p $NOIP_PASSWORD -U 30 -Y
#/usr/local/bin/noip2 -i 10.0.0.1

# Start Nginx
rm /var/www/html/index.nginx-debian.html
echo "<h2>Nobody exists on purpose, nobody belongs anywhere, everybody's gonna die. Come watch TV.</h2><h3>--Morty</h3>" > /var/www/html/index.html
/bin/sed -i "s#NGINX_UWSGI_PASS#${NGINX_UWSGI_PASS}#" /etc/nginx/nginx.conf
grep uwsgi_pass /etc/nginx/nginx.conf
/usr/sbin/nginx

# Setup Certbot
/usr/bin/certbot register -n --agree-tos -m $CERTBOT_USER
/usr/bin/certbot --nginx -n -d $CERTBOT_DOMAIN
# Cron for Certbot
/usr/sbin/cron
(crontab -l 2>/dev/null; echo '0 */12 * * * perl -e "sleep int(rand(60))" && certbot -q renew --post-hook "/usr/sbin/nginx -s reload"') | crontab -
