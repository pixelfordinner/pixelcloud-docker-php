FROM php:5.6-fpm-alpine
LABEL maintainer="Karl Fathi <karl@pixelfordinner.com>"

ENV LANG C.UTF-8

ENV IMAGICK_VERSION 3.4.1

RUN apk add --no-cache \
    zip \
    unzip \
    less \
    mysql-client \
    git \
    curl

# Install PHP extensions.

RUN apk add --update --no-cache --virtual .ext-deps \
    libjpeg-turbo-dev \
    libwebp-dev \
    libpng-dev \
    freetype-dev \
    libmcrypt-dev \
    libzip-dev \
    libxml2-dev \
    icu-dev \
    autoconf \
    g++ \
    libtool \
    make \
    bzip2-dev


RUN apk add --update freetype-dev zlib-dev libzip-dev libpng-dev libjpeg-turbo-dev libxml2-dev icu-dev autoconf g++ imagemagick imagemagick-dev libtool make \
    && docker-php-ext-configure gd \
        --with-jpeg-dir=/usr/include \
        --with-png-dir=/usr/include \
        --with-webp-dir=/usr/include \
        --with-freetype-dir=/usr/include \
    && docker-php-ext-configure zip --with-libzip=/usr/include \
    && docker-php-ext-configure mbstring \
    && docker-php-ext-configure mysqli \
    && docker-php-ext-configure opcache \
    && docker-php-ext-configure soap \
    && docker-php-ext-configure pdo_mysql \
    && docker-php-ext-configure bz2 \
    && docker-php-ext-configure bcmath \
    && docker-php-ext-configure calendar \
    && docker-php-ext-configure exif \
    && docker-php-ext-configure mcrypt \
    && pecl install imagick-$IMAGICK_VERSION \
    && docker-php-ext-install zip gd mbstring mysqli opcache soap intl pdo_mysql bz2 bcmath calendar exif mcrypt

    RUN apk del autoconf g++ libtool make \
    && rm -rf /tmp/* /var/cache/apk/*



# local php.ini
COPY data/conf.d/* /usr/local/etc/php/conf.d/

# Entrypoint
COPY data/entrypoint.sh /usr/local/bin/
RUN chmod +x /usr/local/bin/entrypoint.sh

RUN mkdir -p /opt/www

VOLUME ["/opt/www"]

EXPOSE 9000

CMD ["entrypoint.sh"]
