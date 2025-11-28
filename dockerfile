FROM php:7.4-apache

# --- Install system dependencies ---
RUN apt-get update && apt-get install -y \
    curl wget zip unzip git tidy \
    libxml2-dev libzip-dev libcurl4-openssl-dev \
    libonig-dev libtidy-dev libmcrypt-dev php-pear php-dev

# --- Install PHP Extensions ---
RUN docker-php-ext-install mysqli pdo pdo_mysql xml zip mbstring tidy

# --- Install mcrypt using PECL ---
RUN pecl install mcrypt-1.0.4 && \
    echo "extension=mcrypt.so" > /usr/local/etc/php/conf.d/mcrypt.ini

# --- Enable Apache mod_rewrite ---
RUN a2enmod rewrite

# --- Set Apache DocumentRoot ---
RUN sed -i 's|/var/www/html|/var/www/html/tao|g' /etc/apache2/sites-available/000-default.conf

# --- Configure Directory permissions ---
RUN echo "<Directory /var/www/html/tao>\n\
        Options FollowSymLinks MultiViews\n\
        AllowOverride All\n\
        Require all granted\n\
</Directory>" >> /etc/apache2/apache2.conf

# --- Install Composer (downgrade to v1 for TAO) ---
RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer && \
    composer self-update --1

# --- Download TAO package ---
WORKDIR /var/www/html
RUN wget https://github.com/oat-sa/package-tao/releases/download/3.6.0/tao_3.6.0.zip
RUN unzip tao_3.6.0.zip && mv tao tao && rm tao_3.6.0.zip

WORKDIR /var/www/html/tao

# --- Install TAO dependencies ---
RUN composer install --no-interaction --prefer-dist

# --- Install MathJax ---
RUN wget https://hub.taotesting.com/resources/taohub-articles/articles/third-party/MathJax_Install_TAO_3x.sh && \
    chmod +x MathJax_Install_TAO_3x.sh && \
    ./MathJax_Install_TAO_3x.sh

# --- Startup script to auto-install TAO ---
COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]
CMD ["apache2-foreground"]
