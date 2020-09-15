FROM kalicki2k/alpine-apache:3.11

MAINTAINER weijer

COPY Dockerfiles/. /

RUN apk update && apk upgrade && \
    apk add curl git mysql-client \
            php7.4 php7.4-apache2 php7.4-apcu php7.4-bcmath php7.4-ctype php7.4-curl php7.4-dom php7.4-fileinfo php7.4-gd php7.4-iconv php7.4-imap php7.4-intl \
            php7.4-json php7.4-mbstring php7.4-mcrypt php7.4-mysqli php7.4-opcache php7.4-openssl php7.4-pgsql php7.4-pdo php7.4-pdo_mysql php7.4-phar \
            php7.4-session php7.4-simplexml php7.4-soap php7.4-sqlite3 php7.4-tidy php7.4-tokenizer php7.4-xml php7.4-xmlrpc php7.4-xmlreader php7.4-xmlwriter php7.4-xsl php7.4-zip php7.4-zlib && \
    curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer && \
    chmod +x /run.sh && \
    rm -rf /var/www/localhost/htdocs && \
    rm -rf /var/cache/apk/*

WORKDIR /var/www/localhost

EXPOSE 80 443

ENTRYPOINT ["/run.sh"]