#!/bin/bash
hostname EC2-1
yum install httpd -y
service httpd start
chkconfig httpd on
echo "<h1>CloudNet@ EC2-1 Web Server</h1>" > /var/www/html/index.html