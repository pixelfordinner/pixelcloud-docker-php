FROM php:7.2-fpm-alpine
LABEL maintainer="Karl Fathi <karl@pixelfordinner.com>"

ENV LANG C.UTF-8

ENV IMAGICK_VERSION 3.4.3

RUN apk add --no-cache \
    zip \
    unzip \
    less \
    mysql-client \
    git \
    curl

# Install PHP extensions.

RUN apk add --update freetype-dev libpng-dev libjpeg-turbo-dev libxml2-dev autoconf g++ imagemagick imagemagick-dev libtool make \
    && docker-php-ext-configure gd \
        --with-gd \
        --with-freetype-dir=/usr/include/ \
        --with-png-dir=/usr/include/ \
        --with-jpeg-dir=/usr/include/ \
    && docker-php-ext-install gd \
    && docker-php-ext-install mbstring \
    && docker-php-ext-install mysqli \
    && docker-php-ext-install opcache \
    && docker-php-ext-install soap \
    && pecl install imagick-$IMAGICK_VERSION \
    && docker-php-ext-enable imagick \
    && apk del autoconf g++ libtool make \
    && rm -rf /tmp/* /var/cache/apk/*


# Utilities

# wp-cli
ADD https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar /usr/local/bin/wp
RUN chmod +rx /usr/local/bin/wp

# composer
RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer.phar
RUN chmod +rx /usr/local/bin/composer.phar
ADD data/composer.sh /usr/local/bin/composer
RUN chmod +x /usr/local/bin/composer

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

