FROM openresty/openresty:1.21.4.1-buster

RUN apt-get -y update
RUN apt-get -y install make nginx-extras lua5.1 luarocks
RUN luarocks install luaposix
RUN luarocks install JSON4Lua

RUN mkdir -p /ngx-vagrant/hosted
ADD ./app /ngx-vagrant/app
WORKDIR /ngx-vagrant

RUN rm /etc/nginx/sites-available/default
RUN rm /etc/nginx/conf.d/default.conf
RUN ln -s /ngx-vagrant/app/nginx.conf /etc/nginx/conf.d/default.conf

RUN apt-get clean && \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* ~/.cache
