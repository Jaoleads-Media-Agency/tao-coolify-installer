FROM php:7.4-apache

############################################
# 1. Update apt and install required libraries
############################################
RUN apt-get update && apt-get install -y \
    curl wget zip unzip git \
    build-essential autoconf pkg-config \
    libxml2-dev libzip-dev libcurl4-openssl-dev libonig-dev \
    libicu-dev libpng-dev libjpeg-dev libfreetype6-dev libmcrypt-dev \
    libssl-dev libxslt-dev zlib1g-dev libreadline-dev libsqlite3-dev \
    libtidy-dev tidy libgmp-dev libpq-dev

############################################
# 2. Install all required PHP extensions
############################################
RUN docker-php-ext-install \
    mysqli pdo pdo_mysql pdo_sqlite xml zip mbstring tidy intl soap gd bcmath calendar exif gmp pcntl opcache sockets sysvmsg sysvsem sysvshm \
    && docker-php-ext-enable opcache

############################################
# 3. Install PECL extensions
############################################
RUN pecl install mcrypt-1.0.4 xdebug-3.3.1 || true
RUN docker-php-ext-enable mcrypt xdebug

############################################
# 4. Enable Apache rewrite
############################################
RUN a2enmod rewrite

############################################
# 5. Set DocumentRoot to /var/www/html/tao
############################################
RUN sed -i 's|/var/www/html|/var/www/html/tao|g' /etc/apache2/sites-available/000-default.conf
RUN echo "<Directory /var/www/html/tao>\n\
        Options FollowSymLinks MultiViews\n\
        AllowOverride All\n\
        Require all granted\n\
</Directory>" >> /etc/apache2/apache2.conf

############################################
# 6. Install Composer v1 with unlimited memory
############################################
RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer
RUN composer self-update --1
ENV COMPOSER_MEMORY_LIMIT=-1

############################################
# 7. Download TAO 3.6.0
############################################
WORKDIR /var/www/html
RUN wget https://github.com/oat-sa/package-tao/archive/refs/tags/3.6.0.zip -O tao_3.6.0.zip

############################################
# 8. Unzip TAO correctly
############################################
RUN unzip tao_3.6.0.zip \
    && mv package-tao-3.6.0 tao \
    && rm tao_3.6.0.zip

############################################
# 9. Install TAO dependencies
############################################
WORKDIR /var/www/html/tao
RUN composer install --no-interaction --prefer-dist --ignore-platform-reqs --verbose

############################################
# 10. Install MathJax
############################################
RUN wget https://hub.taotesting.com/resources/taohub-articles/articles/third-party/MathJax_Install_TAO_3x.sh -O mathjax.sh \
    && chmod +x mathjax.sh \
    && ./mathjax.sh || true

############################################
# 11. Entrypoint
############################################
COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]
CMD ["apache2-foreground"]
