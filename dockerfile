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
# 4. Install PHP build dependencies
############################################
RUN apt-get install -y build-essential php7.4-dev

############################################
# 5. Install extra PHP libs
############################################
RUN apt-get install -y libxml2-dev libzip-dev libcurl4-openssl-dev libonig-dev

############################################
# 6. Install PHP extensions (core ones)
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
# 8. Enable Apache modules
############################################
RUN a2enmod rewrite

############################################
# 9. Adjust DocumentRoot
############################################
RUN sed -i 's|/var/www/html|/var/www/html/tao|g' /etc/apache2/sites-available/000-default.conf

############################################
# 10. Add Directory block
############################################
RUN echo "<Directory /var/www/html/tao>\n\
        Options FollowSymLinks MultiViews\n\
        AllowOverride All\n\
        Require all granted\n\
</Directory>" >> /etc/apache2/apache2.conf

############################################
# 11. Install Composer
############################################
RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer

############################################
# 12. Downgrade Composer to v1 (TAO requirement)
############################################
RUN composer self-update --1

############################################
# 13. Download TAO package
############################################
WORKDIR /var/www/html
RUN wget https://github.com/oat-sa/package-tao/releases/download/3.6.0/tao_3.6.0.zip

############################################
# 14. Unzip TAO
############################################
RUN unzip tao_3.6.0.zip && mv tao tao && rm tao_3.6.0.zip

############################################
# 15. Composer install for TAO
############################################
WORKDIR /var/www/html/tao
RUN composer install --no-interaction --prefer-dist

############################################
# 16. Install MathJax
############################################
RUN wget https://hub.taotesting.com/resources/taohub-articles/articles/third-party/MathJax_Install_TAO_3x.sh
RUN chmod +x MathJax_Install_TAO_3x.sh
RUN
