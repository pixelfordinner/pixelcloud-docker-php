FROM php:8.2-fpm-alpine
LABEL maintainer="Karl Fathi <karl@pixelfordinner.com>"

ENV LANG C.UTF-8

ENV IMAGICK_VERSION 3.7.0

RUN apk add --no-cache \
    zip \
    unzip \
    less \
    mysql-client \
    git \
    libarchive-tools \
    curl

# Install PHP extensions.

RUN apk add --update freetype-dev zlib-dev libzip-dev libpng-dev libjpeg-turbo-dev libwebp-dev libxml2-dev icu-dev autoconf g++ imagemagick imagemagick-dev libtool libgomp make linux-headers \
    && pecl install xdebug \
    && docker-php-ext-enable xdebug \
    && docker-php-ext-configure gd \
        --with-freetype=/usr/include/ \
        --with-jpeg=/usr/include/ \
        --with-webp=/usr/include/ \
    && docker-php-ext-install gd \
    && docker-php-ext-install exif \
    && docker-php-ext-install zip \
    && docker-php-ext-install mysqli \
    && docker-php-ext-install pdo \
    && docker-php-ext-install pdo_mysql \
    && docker-php-ext-enable pdo_mysql \
    && docker-php-ext-install opcache \
    && docker-php-ext-install soap \
    && docker-php-ext-install intl \
    && docker-php-ext-install xml \
    && pecl install imagick-$IMAGICK_VERSION \
    && docker-php-ext-enable imagick \
    && apk del autoconf g++ libtool make \
    && rm -rf /tmp/* /var/cache/apk/*


# Utilities

# wp-cli
RUN curl -sS https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar > /usr/local/bin/wp
RUN chmod +rx /usr/local/bin/wp

# composer
RUN curl -sS  https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer
RUN chmod +rx /usr/local/bin/composer

RUN sed -i -e "s/pm.max_children = 5/pm.max_children = 3/g" /usr/local/etc/php-fpm.d/www.conf

# local php.ini
COPY data/conf.d/* /usr/local/etc/php/conf.d/

# Entrypoint
COPY data/entrypoint.sh /usr/local/bin/
RUN chmod +x /usr/local/bin/entrypoint.sh

RUN mkdir -p /opt/www

VOLUME ["/opt/www"]

EXPOSE 9000

CMD ["entrypoint.sh"]
