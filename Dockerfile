FROM alpine:3.10
LABEL Maintainer="Felipe Pimenta <fhpimenta12@gmail.com>" \
      Description="Lightweight container with Nginx 1.16 & PHP-FPM 7.3 based on Alpine Linux."

# Instala os pacotes do PHP 7.3, Nginx e Supervisor
RUN apk --no-cache --update add php7 php7-fpm php7-mysqli php7-json php7-openssl php7-curl \
    php7-zlib php7-xml php7-phar php7-intl php7-dom php7-xmlreader php7-ctype php7-session \
    php7-mbstring php7-gd nginx supervisor curl bash tzdata && \
    cp /usr/share/zoneinfo/America/Sao_Paulo /etc/localtime && \
    echo "America/Sao_Paulo" > /etc/timezone && \
    apk del tzdata && \
    rm -rf /var/cache/apk/* && \
    curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/bin --filename=composer

# Configuração do nginx
COPY config/nginx.conf /etc/nginx/nginx.conf

# Configuração do PHP-FPM
COPY config/fpm-pool.conf /etc/php7/php-fpm.d/www.conf
COPY config/php.ini /etc/php7/conf.d/custom.ini

# Configuração do supervisord
COPY config/supervisord.conf /etc/supervisor/conf.d/supervisord.conf

# Certifique-se de que os arquivos / pastas necessários pelos processos estejam acessíveis quando forem executados pelo usuário nobody
RUN chown -R nobody.nobody /run && \
  chown -R nobody.nobody /var/lib/nginx && \
  chown -R nobody.nobody /var/tmp/nginx && \
  chown -R nobody.nobody /var/log/nginx && \
  # Cria a pasta root da aplicação
  mkdir -p /var/www/html 

# Transformar a pasta root em volume
VOLUME /var/www/html

# Muda para um usuário não-root (nobody)
USER nobody

# Adiciona a aplicação para o container
WORKDIR /var/www/html
COPY --chown=nobody src/ /var/www/html/

# Exposição da porta do Nginx
EXPOSE 8080

# supervisord irá iniciar o nginx e o php-fpm
CMD ["/usr/bin/supervisord", "-c", "/etc/supervisor/conf.d/supervisord.conf"]