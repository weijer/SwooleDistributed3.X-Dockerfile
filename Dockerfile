FROM centos:centos7

MAINTAINER weijer

ENV SRC_DIR /usr/local
ENV CMAKE_VERSION 3.10.2
ENV PHP_VERSION 7.2.18
ENV SWOOLE_VERSION 4.0.4
ENV PHP_DIR /usr/local/php/${PHP_VERSION}
ENV PHP_INI_DIR /etc/php/${PHP_VERSION}/cli
ENV INIT_FILE ${PHP_INI_DIR}/conf.d
ENV HIREDIS_VERSION 0.13.3
ENV PHPREDIS_VERSION 4.3.0
ENV RABBITMQ_VERSION 0.9.0
ENV AMQP_VERSION 1.9.3
ENV PHPIMAGICK_VERSION 3.4.3
ENV PHPDS_VERSION 1.2.4
ENV PHPINOTIFY_VERSION 2.0.0
ENV SDEBUG_VERSION 2.7
ENV HTTPD_PREFIX /usr/local/apache2

#set ldconf
RUN echo "include /etc/ld.so.conf.d/*.conf" > /etc/ld.so.conf \
    && cd /etc/ld.so.conf.d \
    && echo "/usr/local/lib" > /etc/ld.so.conf.d/libc.conf

# tools
RUN yum -y update

RUN yum -y install \
        wget \
        vim \
        gcc \
        make \
        automake \
        autoconf \
        libxml2 \
        libxml2-devel \
        libjpeg-turbo \
        libjpeg-turbo-devel \
        libpng \
        libpng-devel \
        openssl \
        openssl-devel \
        openssh-server \
        curl \
        curl-devel \
        pcre \
        pcre-devel \
        libxslt \
        libxslt-devel \
        freetype-devel \
        bzip2 \
        bzip2-devel \
        libedit \
        libedit-devel \
        glibc-headers \
        gcc-c++ \
        git \
        net-tools \
        initscripts \
        unzip \
        zip \
        openldap \
        openldap-devel \
        epel-release \
        libicu-devel \
        libunwind \
        libicu \
        ImageMagick \
        ImageMagick-devel \
        python-setuptools \
        rabbitmq-server \
        librabbitmq \
        librabbitmq-devel \
    && cp -frp /usr/lib64/libldap* /usr/lib/  \
    && rm -rf /var/cache/{yum,ldconfig}/* \
    && rm -rf /etc/ld.so.cache \
    && yum clean all

# 安装Cmake
ADD install/cmake-${CMAKE_VERSION}.tar.gz ${SRC_DIR}/
RUN cd ${SRC_DIR}/cmake-${CMAKE_VERSION} \
    && ./bootstrap \
    && gmake \
    && gmake install \
    && rm -f ${SRC_DIR}/cmake-${CMAKE_VERSION}.tar.gz

RUN easy_install supervisor

# 配置Apache
ADD install-httpd.sh /
RUN chmod +x /install-httpd.sh
RUN sed -i 's/\r//' /install-httpd.sh
RUN bash -c "/install-httpd.sh"
ADD config/httpd/ /usr/local/apache2/conf
RUN ln -sf /dev/stdout /usr/local/apache2/logs/access_log
RUN ln -sf /dev/stdout /usr/local/apache2/logs/error_log

# 安装php
ADD install/php-${PHP_VERSION}.tar.gz ${SRC_DIR}/
RUN cd ${SRC_DIR}/php-${PHP_VERSION} \
    && ln -s /usr/lib64/libssl.so /usr/lib \
    && ./configure --prefix=${PHP_DIR} \
        --with-config-file-path=${PHP_INI_DIR} \
       	--with-config-file-scan-dir="${PHP_INI_DIR}/conf.d" \
       --disable-cgi \
       --enable-fpm \
       --enable-bcmath \
       --enable-mbstring \
       --enable-mysqlnd \
       --enable-opcache \
       --enable-pcntl \
       --enable-fileinfo \
       --enable-xml \
       --enable-zip \
       --enable-intl \
       --enable-sockets \
       --with-curl \
       --with-png-dir \
       --with-jpeg-dir \
       --with-gd \
       --with-gettext \
       --with-freetype-dir \
       --with-libedit \
       --with-openssl \
       --with-zlib \
       --with-curl \
       --with-mysqli \
       --with-pdo-mysql \
       --with-pear \
       --with-zlib \
       --with-ldap \
       --with-jpeg-dir=/usr \
    && sed -i '/^EXTRA_LIBS/ s/$/ -llber/' Makefile \
    && make clean > /dev/null \
    && make \
    && make install \
    && ln -s ${PHP_DIR}/bin/php /usr/local/bin/ \
    && ln -s ${PHP_DIR}/bin/phpize /usr/local/bin/ \
    && ln -s ${PHP_DIR}/bin/pecl /usr/local/bin/ \
    && ln -s ${PHP_DIR}/bin/php-config /usr/local/bin/ \
    && mkdir -p ${PHP_INI_DIR}/conf.d \
    && cp ${SRC_DIR}/php-${PHP_VERSION}/php.ini-production ${PHP_INI_DIR}/php.ini \
    && echo -e "opcache.enable=1\nopcache.enable_cli=1\nzend_extension=opcache.so" > ${PHP_INI_DIR}/conf.d/10-opcache.ini \
    && rm -f ${SRC_DIR}/php-${PHP_VERSION}.tar.gz \
    && rm -rf ${SRC_DIR}/php-${PHP_VERSION}

# php-fpm配置文件
COPY config/php-fpm/php-fpm-7.2.conf /usr/local/php/7.2.18/etc/php-fpm.conf

#  hiredis
ADD install/hiredis-${HIREDIS_VERSION}.tar.gz ${SRC_DIR}/
RUN cd ${SRC_DIR}/hiredis-${HIREDIS_VERSION} \
    && make clean > /dev/null \
    && make \
    && make install \
    && ldconfig \
    && rm -f ${SRC_DIR}/hiredis-${HIREDIS_VERSION}.tar.gz \
    && rm -rf ${SRC_DIR}/hiredis-${HIREDIS_VERSION}

#  swoole
ADD install/swoole-${SWOOLE_VERSION}.tar.gz ${SRC_DIR}/
RUN cd ${SRC_DIR}/swoole-src-${SWOOLE_VERSION} \
    && phpize \
    && ./configure --enable-async-redis --enable-openssl --enable-mysqlnd --enable-coroutine \
    && make clean > /dev/null \
    && make \
    && make install \
    && echo "extension=swoole.so" > ${INIT_FILE}/swoole.ini \
    && rm -f ${SRC_DIR}/swoole-${SWOOLE_VERSION}.tar.gz \
    && rm -rf ${SRC_DIR}/swoole-src-${SWOOLE_VERSION}

#  redis
ADD install/redis-${PHPREDIS_VERSION}.tar.gz ${SRC_DIR}/
RUN cd ${SRC_DIR}/phpredis-${PHPREDIS_VERSION} \
    && phpize \
    && ./configure \
    && make clean > /dev/null \
    && make \
    && make install \
    && echo "extension=redis.so" > ${INIT_FILE}/redis.ini \
    && rm -f ${SRC_DIR}/redis-${PHPREDIS_VERSION}.tar.gz \
    && rm -rf ${SRC_DIR}/phpredis-${PHPREDIS_VERSION}

# rabbitmq-c
ADD install/rabbitmq-c-${RABBITMQ_VERSION}.tar.gz ${SRC_DIR}/
RUN cd ${SRC_DIR}/rabbitmq-c-${RABBITMQ_VERSION} \
    && mkdir build && cd build \
    && cmake -DCMAKE_INSTALL_PREFIX=/usr/local/rabbitmq-c .. \
    && cmake --build .  --target install \
    && ln -s lib64 lib \
    && rm -f ${SRC_DIR}/rabbitmq-c-${RABBITMQ_VERSION}.tar.gz

# amqp
ADD install/amqp-${AMQP_VERSION}.tar.gz ${SRC_DIR}/
RUN cd ${SRC_DIR}/amqp-${AMQP_VERSION} \
    && phpize \
    && ./configure --with-php-config=${PHP_DIR}/bin/php-config --with-amqp --with-librabbitmq-dir=/usr/local/rabbitmq-c/ \
    && make clean > /dev/null \
    && make \
    && make install \
    && echo "extension=amqp.so" > ${INIT_FILE}/amqp.ini \
    && rm -f ${SRC_DIR}/amqp-${AMQP_VERSION}.tar.gz

# imagick
ADD install/imagick-${PHPIMAGICK_VERSION}.tgz ${SRC_DIR}/
RUN cd ${SRC_DIR}/imagick-${PHPIMAGICK_VERSION} \
    && phpize \
    && ./configure --with-imagick=/usr/local/imagemagick \
    && make clean > /dev/null \
    && make \
    && make install \
    && echo "extension=imagick.so" > ${INIT_FILE}/imagick.ini \
    && rm -f ${SRC_DIR}/imagick-${PHPIMAGICK_VERSION}.tgz \
    && rm -rf ${SRC_DIR}/imagick-${PHPIMAGICK_VERSION}

#  ds
ADD install/ds-${PHPDS_VERSION}.tar.gz ${SRC_DIR}/
RUN cd ${SRC_DIR}/extension-${PHPDS_VERSION} \
    && phpize \
    && ./configure \
    && make clean > /dev/null \
    && make \
    && make install \
    && echo "extension=ds.so" > ${INIT_FILE}/ds.ini \
    && rm -f ${SRC_DIR}/ds-${PHPDS_VERSION}.tar.gz \
    && rm -rf ${SRC_DIR}/extension-${PHPDS_VERSION}


#  inotify
ADD install/inotify-${PHPINOTIFY_VERSION}.tar.gz ${SRC_DIR}/
RUN cd ${SRC_DIR}/php-inotify-${PHPINOTIFY_VERSION} \
    && phpize \
    && ./configure \
    && make clean > /dev/null \
    && make \
    && make install \
    && echo "extension=inotify.so" > ${INIT_FILE}/inotify.ini \
    && rm -f ${SRC_DIR}/inotify-${PHPINOTIFY_VERSION}.tar.gz \
    && rm -rf ${SRC_DIR}/php-inotify-${PHPINOTIFY_VERSION}


# sdebug
ADD install/sdebug-${SDEBUG_VERSION}.tar.gz ${SRC_DIR}/
RUN cd ${SRC_DIR}/sdebug-${SDEBUG_VERSION} \
    && ./rebuild.sh \
    && phpize \
    && ./configure --enable-xdebug --with-php-config=${PHP_DIR}/bin/php-config \
    && make clean > /dev/null \
    && make \
    && make install \
    && echo "zend_extension=xdebug.so" > ${INIT_FILE}/xdebug.ini \
    && rm -f ${SRC_DIR}/amqp-${SDEBUG_VERSION}.tar.gz

# composer
RUN curl -sS https://getcomposer.org/installer | php \
    && mv composer.phar /usr/local/bin/composer

COPY ./config/* ${INIT_FILE}/

# ADD Source
ADD app/ /usr/local/apache2/htdocs/app

# Working dir
WORKDIR $HTTPD_PREFIX

# 拷贝项目代码


# Run
COPY supervisord.conf /etc/supervisor/supervisord.conf
CMD ["/usr/bin/supervisord"]
EXPOSE 80
