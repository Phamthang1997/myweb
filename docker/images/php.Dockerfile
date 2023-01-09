FROM php:fpm
WORKDIR "/var/www/html"

RUN apt-get update
RUN apt-get install -y libzip-dev zip
RUN docker-php-ext-install zip pdo pdo_mysql mysqli
RUN pecl install -o -f redis && docker-php-ext-enable redis
RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer
RUN pecl install xdebug && docker-php-ext-enable xdebug
RUN docker-php-ext-install opcache
RUN apt-get install curl
RUN apt-get clean
RUN rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* /usr/share/doc/*
