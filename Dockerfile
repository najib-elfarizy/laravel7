# Gunakan PHP 7.4 dengan Apache
FROM php:7.4-apache

# Install dependensi yang diperlukan
RUN apt-get update && apt-get install -y \
    libpng-dev \
    libjpeg62-turbo-dev \
    libfreetype6-dev \
    libzip-dev \
    git \
    unzip \
    && rm -rf /var/lib/apt/lists/*

# Install ekstensi PHP yang dibutuhkan oleh Laravel
RUN docker-php-ext-configure gd --with-freetype --with-jpeg \
    && docker-php-ext-install gd zip pdo pdo_mysql

# Install Composer (manajer dependensi PHP)
RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer

# Menyalin file konfigurasi Apache dan kode aplikasi Laravel
COPY apache/000-default.conf /etc/apache2/sites-available/000-default.conf
COPY . /var/www/html

# Mengatur izin yang benar untuk aplikasi Laravel
RUN chown -R www-data:www-data /var/www/html
RUN chmod -R 755 /var/www/html

# Set direktori kerja untuk aplikasi Laravel
WORKDIR /var/www/html

# Menjalankan composer untuk menginstal dependensi Laravel
RUN composer install --no-dev --optimize-autoloader

# Enable mod_rewrite untuk Apache
RUN a2enmod rewrite

# Expose port 80 untuk mengakses aplikasi
EXPOSE 80

# Menjalankan Apache dalam mode foreground
CMD ["apache2-foreground"]
