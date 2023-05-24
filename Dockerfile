FROM php:7.3-apache
RUN \
  apt-get update && \
  apt-get install -y \
  curl \
  wget \
  git

RUN \ 
  apt-get update && \
  apt-get upgrade -y

RUN \
  apt -y install lsb-release apt-transport-https ca-certificates && \
  wget -O /etc/apt/trusted.gpg.d/php.gpg https://packages.sury.org/php/apt.gpg &&\
  echo "deb https://packages.sury.org/php/ $(lsb_release -sc) main" | tee /etc/apt/sources.list.d/php.list

RUN \
  apt-get update && \
  apt-get install -y \
  locales \
  iptables \
  apt-transport-https \
  nano \
  && apt-get clean && apt-get autoclean && apt-get autoremove \
  && rm -rf /var/lib/apt/lists/*

RUN apt-get update
RUN apt-get install software-properties-common -y
RUN apt-get update

#RUN \
#   apt-get install php7.3-dev -y 

RUN apt-get update && apt-get install -y \
  && apt-get update

# Install Dependencies
RUN ACCEPT_EULA=Y apt-get install -y \
  locales \
  && echo "en_US.UTF-8 UTF-8" > /etc/locale.gen && locale-gen

# Install OCI8 from PECL.
RUN apt-get update

RUN apt-get update && apt-get install -qqy git unzip libfreetype6-dev \
  libjpeg62-turbo-dev \
  libpng-dev \
  libaio1 wget && apt-get clean autoclean && apt-get autoremove --yes &&  rm -rf /var/lib/{apt,dpkg,cache,log}/ 
#composer
RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer

# ORACLE oci 
RUN mkdir /opt/oracle \
  && cd /opt/oracle     

ADD ./DockerDependences/instantclient-basic-linux.x64-12.1.0.2.0.zip /opt/oracle
ADD ./DockerDependences/instantclient-sdk-linux.x64-12.1.0.2.0.zip /opt/oracle

# Install Oracle Instantclient
RUN  unzip /opt/oracle/instantclient-basic-linux.x64-12.1.0.2.0.zip -d /opt/oracle \
  && unzip /opt/oracle/instantclient-sdk-linux.x64-12.1.0.2.0.zip -d /opt/oracle \
  && ln -s /opt/oracle/instantclient_12_1/libclntsh.so.12.1 /opt/oracle/instantclient_12_1/libclntsh.so \
  && ln -s /opt/oracle/instantclient_12_1/libclntshcore.so.12.1 /opt/oracle/instantclient_12_1/libclntshcore.so \
  && ln -s /opt/oracle/instantclient_12_1/libocci.so.12.1 /opt/oracle/instantclient_12_1/libocci.so \
  && rm -rf /opt/oracle/*.zip

ENV LD_LIBRARY_PATH  /opt/oracle/instantclient_12_1:${LD_LIBRARY_PATH}

RUN export PHP_DTRACE=yes
# Install Oracle extensions
RUN echo 'instantclient,/opt/oracle/instantclient_12_1/' | pecl install oci8-2.2.0 

ADD ./DockerDependences/php.ini /usr/local/etc/php


RUN \
  docker-php-ext-configure pdo_oci --with-pdo-oci='instantclient,/opt/oracle/instantclient_12_1,12.1' \
  && docker-php-ext-install \
  pdo_oci 

RUN docker-php-ext-install mysqli && docker-php-ext-enable mysqli
RUN docker-php-ext-install pdo pdo_mysql

RUN pecl install xdebug-3.1.6 \
  && docker-php-ext-enable xdebug

RUN apt-get update \
  && apt-get -y --no-install-recommends install  php-xdebug \
  && apt-get clean; rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* /usr/share/doc/*

ADD ./DockerDependences/docker-php-ext-xdebug.ini /usr/local/etc/php/conf.d/

VOLUME /var/www/html
#ADD . /var/www/html/
LABEL Description=" Apache 2.4.7 Webserver - PHP 7.3"
EXPOSE 80
