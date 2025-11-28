FROM php:7.4-apache

############################################
# 1. Update apt
############################################
RUN apt-get update

############################################
# 2. Install base utilities
############################################
RUN apt-get install -y curl wget zip unzip git

############################################
# 3. Install tidy + libs
############################################
RUN apt-get install -y tidy libtidy-dev

############################################
# 4. Install build tools for PECL modules
############################################
RUN apt-get install -y build-essential autoconf

############################################
# 5. Install PHP extension dependencies
############################################
RUN apt-get install -y libxml2-dev libzip-dev libcurl4-openssl-dev libonig-dev

############################################
# 6. Install PHP extensions one-by-one
############################################
RUN docker-php-ext-install mysqli
RUN docker-php-ext-install pdo pdo_mysql
RUN docker-php-ext-install xml
RUN docker-php-ext-install zip
RUN docker-php-ext-install mbstring
RUN docker-php-ext-install tidy

############################################
# 7. Install mcrypt via PECL
############################################
RUN pecl install mcrypt-1.0.4 || true
RUN echo "extension=mcrypt.so" > /usr/local/etc/php/conf.d/mcrypt.ini

############################################
# 8. Enable Apache rewrite
############################################
RUN a2enmod rewrite

############################################
# 9. Change DocumentRoot
############################################
RUN sed -i 's|/var/www/html|/var/www/html/tao|g' /etc/apache2/sites-available/000-default.conf

############################################
# 10. Directory permissions block
############################################
RUN echo "<Directory /var/www/html/tao>\n\
        Options FollowSymLinks MultiViews\n\
        AllowOverride All\n\
        Require all granted\n\
</Directory>" >> /etc/apache2/apache2.conf

############################################
# 11. Install Composer (v1 required)
############################################
RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer
RUN composer self-update --1

############################################
# 12. Download TAO 3.6.0
############################################
WORKDIR /var/www/html
RUN wget https://github.com/oat-sa/package-tao/archive/refs/tags/3.6.0.zip

############################################
# 13. Unzip TAO
############################################
RUN unzip tao_3.6.0.zip && mv tao tao && rm tao_3.6.0.zip

############################################
# 14. Install TAO dependencies
############################################
WORKDIR /var/www/html/tao
RUN composer install --no-interaction --prefer-dist

############################################
# 15. Install MathJax
############################################
RUN wget https://hub.taotesting.com/resources/taohub-articles/articles/third-party/MathJax_Install_TAO_3x.sh
RUN chmod +x MathJax_Install_TAO_3x.sh
RUN ./MathJax_Install_TAO_3x.sh || true

############################################
# 16. Entrypoint
############################################
COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]
CMD ["apache2-foreground"]
