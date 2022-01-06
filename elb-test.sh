#!/bin/bash
apt-get update
apt-get -y install net-tools nginx
MYIP=`ifconfig | grep -E '(inet 10)' | awk '{ print $2 }' | cut -d ':' -f 2`
echo "This is my IP: " $MYIP > /var/www/html/index.html

# Install stress so that we can load the instances to test out the autoscaling service
<< comment 
apt-get install stress
stress --cpu 2 --timeout 300 
comment