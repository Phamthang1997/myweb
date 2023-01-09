
<p align="center"><a href="https://laravel.com" target="_blank"><img src="https://raw.githubusercontent.com/laravel/art/master/logo-lockup/5%20SVG/2%20CMYK/1%20Full%20Color/laravel-logolockup-cmyk-red.svg" width="400" alt="Laravel Logo"></a></p>

<p align="center">
<a href="https://travis-ci.org/laravel/framework"><img src="https://travis-ci.org/laravel/framework.svg" alt="Build Status"></a>
<a href="https://packagist.org/packages/laravel/framework"><img src="https://img.shields.io/packagist/dt/laravel/framework" alt="Total Downloads"></a>
<a href="https://packagist.org/packages/laravel/framework"><img src="https://img.shields.io/packagist/v/laravel/framework" alt="Latest Stable Version"></a>
<a href="https://packagist.org/packages/laravel/framework"><img src="https://img.shields.io/packagist/l/laravel/framework" alt="License"></a>
</p>

## Deploy with docker
Directory of docker:
<pre>
<b>docker</b>
-- config
---- nginx
---- php-fpm
-- data
-- images
-- logs
---- nginx_log
---- php-fpm
<b>projects</b>
-- myweb.local
</pre>
## Create docker files
1.  Create a file <b>myweb.local.conf</b> in <b>docker/config/nginx</b> with code:
    <pre><code>server {
        listen   80;
    	listen [::]:80;
    	  
        root /var/www/html/myweb.local/public;
        index index.php index.html index.htm;
    	client_max_body_size 100M;    
        server_name myweb.local www.myweb.local;
        location / {
            try_files $uri $uri/ /index.php?$query_string;
        }
        location ~ \.php$ {
            try_files $uri $uri/ /index.php?$query_string;
            fastcgi_pass myweb_php:9000;
            fastcgi_index index.php;
            include fastcgi_params;
            fastcgi_param SCRIPT_FILENAME $document_root$fastcgi_script_name;
            fastcgi_param PATH_INFO $fastcgi_path_info;
        }
        location ~* \.(jpg|jpeg|gif|png|css|js|ico|xml)$ {
            expires 1d;
        }
        location ~ /\. {
                log_not_found off;
                deny all;
        }
       }</code></pre>
2.  Create a file <b>custom.ini</b> in <b>docker/config/php-fpm</b> with code:
    <pre><code>post_max_size = 1024M
    upload_max_filesize = 1024M
    error_log = /var/log/php-fpm.log
    display_errors = on
    opcache.enable=0
    memory_limit=1024M
    zend.assertions=-1
    enable_dl=1
    error_reporting=E_ALL & ~E_DEPRECATED & ~E_STRICT</code></pre>
3.  Create a file <b>composer.Dockerfile</b> in <b>docker/images</b> with code:
    <pre><code>FROM composer:latest</code></pre>
4. Create a file <b>mysql.Dockerfile</b> in <b>docker/images</b> with code:
   <pre><code>FROM mysql:8.0.31</code></pre>
5.  Create a file <b>nginx.Dockerfile</b> in <b>docker/images</b> with code:
    <pre><code>FROM nginx:latest</code></pre>
6.  Create a file <b>php.Dockerfile</b> in <b>docker/images</b> with code:
    <pre>
    <code>FROM bitnami/php-fpm:8.1.11
    RUN apt-get update
    RUN apt-get install -y vim
    </code></pre>
7. Create a file <b>.env</b> in <b>docker</b> directory
   <pre><code>COMPOSE_PROJECT_NAME=myweb</code></pre>
8. Create a file <b>docker-compose.yml</b> in <b>docker</b> directory
   <pre><code>
   version: "3"
   services:
       myweb_nginx:
           dns:
             - 8.8.8.8
             - 4.4.4.4
           build:
             context: ./images
             dockerfile: nginx.Dockerfile
           working_dir: /var/www/html
           container_name: myweb_nginx
           ports:
             - "8181:80"
           volumes:
             - ../projects:/var/www/html
             - ./logs/nginx_log:/var/log/nginx
             - ./config/nginx/myweb.local.conf:/etc/nginx/conf.d/myweb.local.conf
           links:
             - myweb_php
             - myweb_mysql
       myweb_php:
           build:
             context: ./images
             dockerfile: php.Dockerfile
           container_name: myweb_php
           restart: always
           volumes:
               - ../projects:/var/www/html
               - ./logs/php-fpm/php-fpm.log:/var/log/php-fpm.log
               - ./config/php-fpm/custom.ini:/opt/bitnami/php/etc/conf.d/custom.ini
       myweb_mysql:
           build:
             context: ./images
             dockerfile: mysql.Dockerfile
           container_name: myweb_mysql
           restart: always
           ports:
             - "3310:3306"
           volumes:
             - ./data/mysql:/var/lib/mysql
           command: [
             --default-authentication-plugin=mysql_native_password,
             --skip-host-cache
           ]
           environment:
             #MYSQL_ALLOW_EMPTY_PASSWORD:
             MYSQL_ROOT_PASSWORD: password
             MYSQL_DATABASE: myweb
             MYSQL_USER: admin
             MYSQL_PASSWORD: password
       myweb_composer:
           build:
               context: ./images
               dockerfile: composer.Dockerfile
           container_name: myweb_composer
           links:
               - myweb_php
   </code>
   </pre>
9. Start build docker with command:
   <p>Note: make sure <b>cd</b> to the <b>docker</b> directory on the terminal</p>
   <p><b>Step 1:</b></p>
   <pre><code>docker-compose build</code></pre>
   After docker build is successful and next step 2
   <p><b>Step 2:</b></p>
   <pre><code>docker-compose up -d</code></pre>
## Setup source code
First, please add the domain to the hosts file of windows or hosts on macos:
<p>Windows : <b>C:\Windows\System32\drivers\etc\hosts</b><br/>
Macos: <b>/etc/hosts</b></p>
<pre><code>127.0.0.1	myweb.local
::1 myweb.local</code></pre>
The source code is located in the directory <b>myweb.local</b>
<pre>
<b>projects</b>
-- myweb.local
</pre>
=> <b>Clone the source code from git</b>

###  Install laravel
Open terminal and run with code :
1.  Composer update
    <pre><code>docker exec myweb_php bash -c "cd /var/www/html/myweb.local && composer update"</code></pre>
2.  Copy .env file from .env.example
    <pre><code>docker exec myweb_php bash -c "cp /var/www/html/myweb.local/.env.example /var/www/html/myweb.local/.env"</code></pre>
3.  Run artisan migrate
    <pre><code>docker exec myweb_php bash -c "cd /var/www/html/myweb.local && php artisan migrate"</code></pre>
4. Run npm install for format code with re-commit
   <p>Note: make sure <b>cd</b> to the <b>myweb.local</b> directory on the terminal</p>
   <pre>
   <b>projects</b>
   -- myweb.local</pre>
   <b>And run</b>
   <pre><code>npm i</code></pre>