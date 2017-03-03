FROM php:7-fpm
MAINTAINER Karl Fathi <karl@pixelfordinner.com>

ENV LANG C.UTF-8

ENV IMAGICK_VERSION 3.4.3

# Install utilities
RUN apt-get update \
    && apt-get install -y \
        imagemagick \
        graphicsmagick \
        zip \
        unzip \
        sudo \
        less \
        mysql-client \
        git \
    && rm -rf /var/lib/apt/lists/*

# gd
RUN buildRequirements="libpng12-dev libjpeg-dev libfreetype6-dev" \
    && apt-get update && apt-get install -y ${buildRequirements} \
    && docker-php-ext-configure gd --with-freetype-dir=/usr/include/ --with-jpeg-dir=/usr/lib \
    && docker-php-ext-install gd \
    && apt-get purge -y ${buildRequirements} \
    && rm -rf /var/lib/apt/lists/*

# pdo_mysql
RUN docker-php-ext-install pdo_mysql

# mysqli
RUN docker-php-ext-install mysqli

# mcrypt
RUN runtimeRequirements="re2c libmcrypt-dev" \
    && apt-get update && apt-get install -y ${runtimeRequirements} \
    && docker-php-ext-install mcrypt \
    && rm -rf /var/lib/apt/lists/*

# mbstring
RUN docker-php-ext-install mbstring

# intl
RUN buildRequirements="libicu-dev g++" \
    && apt-get update && apt-get install -y ${buildRequirements} \
    && docker-php-ext-install intl \
    && apt-get purge -y ${buildRequirements} \
    && runtimeRequirements="libicu52" \
    && apt-get install -y --auto-remove ${runtimeRequirements} \
    && rm -rf /var/lib/apt/lists/*

# imagick
RUN runtimeRequirements="libmagickwand-6.q16-dev --no-install-recommends" \
    && apt-get update && apt-get install -y ${runtimeRequirements} \
    && ln -s /usr/lib/x86_64-linux-gnu/ImageMagick-6.8.9/bin-Q16/MagickWand-config /usr/bin/ \
    && pecl install imagick-$IMAGICK_VERSION\
    && echo "extension=imagick.so" > /usr/local/etc/php/conf.d/ext-imagick.ini \
    && rm -rf /var/lib/apt/lists/*

# opcache
RUN docker-php-ext-install opcache

# zip
RUN docker-php-ext-install zip

# apcu + apcu-bc (For backwards compat)
RUN pecl install apcu \
    && echo "extension=apcu.so" > /usr/local/etc/php/conf.d/ext-apcu.ini

#bz2
RUN buildRequirements="libbz2-dev g++" \
    && apt-get update && apt-get install -y ${buildRequirements} \
    && docker-php-ext-install bz2 \
    && apt-get purge -y ${buildRequirements}

# Utilities

# wp-cli
ADD https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar /usr/local/bin/wp-cli.phar
ADD data/wp.sh /usr/local/bin/wp
RUN chmod +rx /usr/local/bin/wp-cli.phar
RUN chmod +x /usr/local/bin/wp

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
