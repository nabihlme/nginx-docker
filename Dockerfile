FROM ubuntu:latest

# Upgrade
RUN apt-get update
RUN apt-get dist-upgrade -y
RUN apt-get install -y htop wget curl net-tools vim

# Letsencrypt
RUN apt-get install -y software-properties-common
RUN add-apt-repository -y ppa:certbot/certbot
RUN apt-get update
RUN apt-get install -y python-certbot-nginx

# No-IP
RUN apt-get install -y build-essential
WORKDIR /usr/local/src/
RUN wget http://www.no-ip.com/client/linux/noip-duc-linux.tar.gz
#COPY noip-duc-linux.tar.gz noip-duc-linux.tar.gz
RUN tar xf noip-duc-linux.tar.gz
WORKDIR /usr/local/src/noip-2.1.9-1/
RUN make
RUN cp noip2 /usr/local/bin/noip2
WORKDIR /

# Nginx
RUN apt-get install -y nginx
WORKDIR /etc/nginx
RUN openssl req -x509 -nodes -days 36500 -sha256 -newkey rsa:2048 -keyout ssl-cert-snakeoil.key -out ssl-cert-snakeoil.pem -subj '/CN=localhost'
RUN openssl dhparam -out dhparam.pem 2048
EXPOSE 80
EXPOSE 443
WORKDIR /
COPY nginx.conf /etc/nginx/nginx.conf

# Cleanup
RUN apt-get autoremove -y
RUN apt-get clean -y

# Start
COPY init.cfg /usr/local/bin/init.cfg
COPY init.sh /usr/local/bin/init.sh
ENTRYPOINT ["/bin/bash", "/usr/local/bin/init.sh"]
