FROM alpine:edge
LABEL maintainer="weijer <weiwei163@foxmail.com>" version="1.0"

ENV \ COMPOSER_ALLOW_SUPERUSER=1


# PHP.earth Alpine repository for better developer experience
ADD https://repos.php.earth/alpine/phpearth.rsa.pub /etc/apk/keys/phpearth.rsa.pub

RUN set -x \
    && echo "https://repos.php.earth/alpine/v3.9" >> /etc/apk/repositories

RUN apk update && apk add --no-cache bash \
                                  alpine-sdk \
                                  openssl-dev \
                                  nano \
                                  curl \
                                  curl-dev \
                                  php7.4 \
                                  php7.4-intl \
                                  php7.4-apache2 \
                                  php7.4-session \
                                  php7.4-phar \
                                  php7.4-mcrypt \
                                  php7.4-bcmath \
                                  php7.4-calendar \
                                  php7.4-mbstring \
                                  php7.4-exif \
                                  php7.4-ftp \
                                  php7.4-openssl \
                                  php7.4-zip \
                                  php7.4-gd \
                                  php7.4-sysvsem \
                                  php7.4-sysvshm \
                                  php7.4-sysvmsg \
                                  php7.4-shmop \
                                  php7.4-sockets \
                                  php7.4-zlib \
                                  php7.4-bz2 \
                                  php7.4-curl \
                                  php7.4-simplexml \
                                  php7.4-xml \
                                  php7.4-opcache \
                                  php7.4-dom \
                                  php7.4-xmlreader \
                                  php7.4-xmlwriter \
                                  php7.4-tokenizer \
                                  php7.4-ctype \
                                  php7.4-session \
                                  php7.4-fileinfo \
                                  php7.4-iconv \
                                  php7.4-json \
                                  php7.4-mysqli \
                                  php7.4-pdo \
                                  php7.4-pdo_mysql \
                                  php7.4-pdo_sqlite \
                                  php7.4-redis \
                                  php7.4-posix \
                                  php7.4-dev \
                                  php7.4-pear \
                                  php7.4-fpm \
                                  php7.4-pcntl \
                                  php7.4-zip \
                                  php7.4-cgi \
                                  php7.4-bcmath \
                                  apache2 \
                                  libxml2-dev \
                                  apache2-utils \
                                  ca-certificates

RUN  rm -rf /var/cache/apk/*

RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/bin --filename=composer

RUN composer self-update

## 以下 是 swoole
RUN printf "no\n" | pecl install swoole \
   && pecl clear-cache \
   && echo "extension=swoole" >> /etc/php/7.4/php.ini


RUN mkdir /var/www/public/
VOLUME  /var/www/public/
WORKDIR  /var/www/public/

# AllowOverride ALL
RUN sed -i 's#AllowOverride None#AllowOverride All#' /etc/apache2/httpd.conf

# Enable Modules
RUN sed -i 's/#LoadModule\ rewrite_module/LoadModule\ rewrite_module/' /etc/apache2/httpd.conf
#RUN sed -i 's/#LoadModule\ deflate_module/LoadModule\ deflate_module/' /etc/apache2/httpd.conf
#RUN sed -i 's/#LoadModule\ expires_module/LoadModule\ expires_module/' /etc/apache2/httpd.conf

# Document Root to /var/www/public/
RUN sed -i 's#/var/www/localhost/htdocs#/var/www/public#g' /etc/apache2/httpd.conf
RUN sed -i 's/^Listen 80$/Listen 0.0.0.0:80/' /etc/apache2/httpd.conf

# Modify php.ini settings
RUN sed -i 's/memory_limit = .*/memory_limit = 256M/' /etc/php/7.4/php.ini
RUN sed -i 's/opcache.enable=1/opcache.enable_cli=1/zend_extension=opcache.so/' /etc/php/7.4/php.ini
RUN sed -i "s/^;date.timezone =$/date.timezone = \"PRC\"/" /etc/php/7.4/php.ini

EXPOSE 80

ENTRYPOINT ["httpd","-D","FOREGROUND"]