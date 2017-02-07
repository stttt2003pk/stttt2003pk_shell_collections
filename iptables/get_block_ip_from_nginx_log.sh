#!/usr/bin/env bash

author="stttt2003pk"

nginx_home = /usr/local/nginx
log_path = /home/wwwroot/logs

/usr/bin/tail -n 50000 $log_path/access.log  | awk '$8 ~/aspx/{print $2,$13}' \
| grep -i -v -E "google|yahoo|baidu|msnbot|FeedSky|sogou" \
|awk '{print $1}'|sort|uniq -c |sort -rn \
|awk '{if($1>150) print "deny "$2";"}'> $nginx_home/conf/vhosts/blockip.conf

/bin/kill -HUP `cat $nginx_home/nginx.pid`