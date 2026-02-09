FROM php:8.4-fpm

ENV COMPOSER_ALLOW_SUPERUSER=1 \
    APP_ENV=production

RUN apt-get update \
    && apt-get install -y --no-install-recommends \
        git \
        unzip \
        libzip-dev \
        libicu-dev \
        libonig-dev \
        sqlite3 \
        libsqlite3-dev \
        libpng-dev \
        libjpeg62-turbo-dev \
        libfreetype6-dev \
    && docker-php-ext-configure gd --with-freetype --with-jpeg \
    && docker-php-ext-install -j"$(nproc)" \
        bcmath \
        gd \
        intl \
        pdo \
        pdo_sqlite \
        zip \
        opcache \
    && rm -rf /var/lib/apt/lists/*

COPY --from=composer:2 /usr/bin/composer /usr/bin/composer

WORKDIR /var/www/html

COPY . .

COPY docker/entrypoint.sh /usr/local/bin/entrypoint.sh

RUN git config --global --add safe.directory /var/www/html \
    && composer install --no-dev --optimize-autoloader --no-interaction --no-progress \
    && test -f database/database.sqlite || touch database/database.sqlite \
    && chown -R www-data:www-data /var/www/html \
    && chmod -R 775 storage bootstrap/cache \
    && chmod +x /usr/local/bin/entrypoint.sh

EXPOSE 8000

ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]
CMD ["php","-S","0.0.0.0:8000","-t","public"]
