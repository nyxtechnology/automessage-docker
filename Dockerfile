FROM php:8.1-alpine as automessageDownloader
ENV VERSION 0.5
ENV URL https://github.com/nyxtechnology/automessage/archive/refs/heads/stage.zip

RUN install unzip; \
RUN set -ex; \
    curl -fsSL -o automessage-stage.zip $URL; \
    unzip automessage-stage.zip; \
    rm -r automessage-stage.zip 

FROM composer:2.3 AS composerBuilder
COPY --from=automessageDownloader /automessage-stage/composer.lock /app/composer.lock
COPY --from=automessageDownloader /automessage-stage/composer.json /app/composer.json

RUN composer install \
    --ignore-platform-reqs \
    --no-interaction \
    --no-scripts \
    --prefer-dist \
    --no-dev

FROM php:8.1-apache
COPY --chown=www-data:www-data --from=composerBuilder /app/vendor /var/www/html/automessage/vendor
COPY --from=automessageDownloader /automessage-stage/ /var/www/html/automessage
COPY ./.env.example /var/www/html/automessage/.env

ENV APACHE_DOCUMENT_ROOT /var/www/html/automessage/public

RUN sed -ri -e 's!/var/www/html!${APACHE_DOCUMENT_ROOT}!g' /etc/apache2/sites-available/*.conf
RUN sed -ri -e 's!/var/www/!${APACHE_DOCUMENT_ROOT}!g' /etc/apache2/apache2.conf /etc/apache2/conf-available/*.conf

# Install dependencies
WORKDIR /var/www/html
RUN set -ex; \
    apt-get update; \
    apt-get install -y --no-install-recommends \
        libbz2-dev \
        libfreetype6-dev \
        libjpeg-dev \
        libpng-dev \
        libwebp-dev \
        libxpm-dev \
        libzip-dev \
    ; \
    docker-php-ext-configure gd --with-freetype --with-jpeg --with-webp --with-xpm; \
    docker-php-ext-install -j "$(nproc)" \
        bz2 \
        gd \
        mysqli \
        opcache \
    ;
# set recommended PHP.ini settings
# see https://secure.php.net/manual/en/opcache.installation.php
ENV MAX_EXECUTION_TIME 600
ENV MEMORY_LIMIT 512M
ENV UPLOAD_LIMIT 2048K
RUN set -ex; \
    \
    { \
        echo 'opcache.memory_consumption=128'; \
        echo 'opcache.interned_strings_buffer=8'; \
        echo 'opcache.max_accelerated_files=4000'; \
        echo 'opcache.revalidate_freq=2'; \
        echo 'opcache.fast_shutdown=1'; \
    } > $PHP_INI_DIR/conf.d/opcache-recommended.ini; \
    \
    { \
        echo 'session.cookie_httponly=1'; \
        echo 'session.use_strict_mode=1'; \
    } > $PHP_INI_DIR/conf.d/session-strict.ini; \
    \
    { \
        echo 'allow_url_fopen=Off'; \
        echo 'max_execution_time=${MAX_EXECUTION_TIME}'; \
        echo 'max_input_vars=10000'; \
        echo 'memory_limit=${MEMORY_LIMIT}'; \
        echo 'post_max_size=${UPLOAD_LIMIT}'; \
        echo 'upload_max_filesize=${UPLOAD_LIMIT}'; \
    } > $PHP_INI_DIR/conf.d/phpmyadmin-misc.ini

LABEL org.opencontainers.image.title="Official Automessage Docker image" \
    org.opencontainers.image.description="Run automessage with Alpine, Apache and PHP FPM." \
    org.opencontainers.image.authors="The automessage Team <admin@nyc.tc>" \
    org.opencontainers.image.vendor="Automessage" \
    org.opencontainers.image.documentation="https://github.com/nyxtechnology/automessage-documentation" \
    org.opencontainers.image.licenses="GPL-2.0-only" \
    org.opencontainers.image.version="${VERSION}" \
    org.opencontainers.image.url="https://github.com/nyxtechnology/automessage" \
    org.opencontainers.image.source="https://github.com/nyxtechnology/automessage"

RUN set -ex; \
    apt-get update; \
    apt-get install -y apt-utils; \
    apt-get install -y --no-install-recommends \
        gnupg \
        dirmngr

RUN chown www-data:www-data . -R

CMD ["apache2-foreground"]
