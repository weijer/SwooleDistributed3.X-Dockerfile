#!/bin/bash
# Make sure we're not confused by old, incompletely-shutdown httpd
# context after restarting the container.  httpd won't start correctly
# if it thinks it is already running.
# exec /usr/local/php/7.2.18/sbin/php-fpm -F
# exec httpd
rm -f /usr/local/apache2/logs/httpd.pid
# exec /usr/local/apache2/bin/httpd -DFOREGROUND
