FROM php:7.4-fpm

ARG XDEBUG=0

RUN docker-php-ext-install pdo pdo_mysql && \
	# Install LDAP, libzip, libpng (for gd), locales:
	apt-get update && \
	apt-get install -y --no-install-recommends libldap2-dev libzip-dev libpng-dev locales-all && \
	# Configure and install LDAP, ZIP and gd:
    docker-php-ext-configure ldap --with-libdir=lib/x86_64-linux-gnu/ && \
    docker-php-ext-install ldap zip gd && \
    # Remove libldap and libzip as they are no longer necessary
    apt-get purge -y --auto-remove libldap2-dev libzip-dev && \
	rm -r /var/lib/apt/lists/* && \
	#
    printf '[PHP]\ndate.timezone = "America/Boa_Vista"\n' > /usr/local/etc/php/conf.d/tzone.ini

RUN if [ "${XDEBUG}" = "1" ]; then \
        pecl install xdebug && \
        docker-php-ext-enable xdebug && \
        touch "/var/log/xdebug.log" && \
        chown www-data:www-data "/var/log/xdebug.log" && \
        echo \ 
            "xdebug.default_enable=1\n"\
            "xdebug.remote_enable=1\n"\
            "xdebug.remote_autostart=1\n"\
            "xdebug.remote_host=host.docker.internal\n"\
            "xdebug.remote_log=/var/log/xdebug.log" >> /usr/local/etc/php/conf.d/docker-php-ext-xdebug.ini \
    ; fi

