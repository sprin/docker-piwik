FROM centos:7.1.1503
MAINTAINER Steffen Prince <steffen@sprin.io>

EXPOSE 8080

# Disable fastermirror plugin - not using it is actually faster.
RUN sed -ri 's/^enabled=1/enabled=0/' /etc/yum/pluginconf.d/fastestmirror.conf

# Set LANG and LC_ALL
ENV LANG='en_US.UTF-8' LC_ALL='en_US.UTF-8'

# Install EPEL and unzip
RUN yum install -y \
    epel-release \
    unzip \
    && yum clean all

# Install php
RUN yum install -y \
    php-pdo \
    php-gd \
    php-xml \
    php-mysql \
    php-mbstring \
    php \
    && yum clean all

# TODO: Fix PHP raw post data setting
# RUN sed -i 's/;always_populate_raw_post_data/always_populate_raw_post_data/g' /etc/php5/fpm/php.ini

# Create a healthcheck.html for haproxy/external uptime monitoring checks
RUN /bin/echo OK > /var/www/healthcheck.html

# Install uwsgi
RUN yum install -y \
    uwsgi \
    uwsgi-router-cache \
    uwsgi-plugin-php \
    && yum clean all

CMD ["/usr/sbin/uwsgi", "--ini", "/etc/uwsgi/uwsgi.ini"]

# Fetch Piwik
WORKDIR /var/www
RUN curl -LO http://builds.piwik.org/piwik.zip  \
    && unzip -oq piwik.zip -d /var/www/ \
    && mv piwik/* /var/www/ \
    && rmdir piwik \
    && rm piwik.zip

COPY uwsgi.ini /etc/uwsgi/uwsgi.ini
COPY config.ini.php /piwik/config/config.ini.php

