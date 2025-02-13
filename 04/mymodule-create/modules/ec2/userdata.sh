#!/bin/bash
# 웹 서버 설치
yum install -y httpd mod_ssl

# 웹 컨텐츠
echo "<html><h1>Hello World</h1></html>" > /var/www/html/index.html

# 서비스 시작
systemctl enable --now httpd