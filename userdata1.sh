#!/bin/bash

#Installing httpd package
yum install httpd -y

#starting the httpd service
systemctl enable --now httpd

#adding index.html for the /var/www/html
echo "<h1>My machine hostname is $(hostname)</h1>" >> /var/www/html/index.html

#restarting the httpd service
systemctl restart httpd
