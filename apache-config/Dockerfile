FROM httpd:latest

# Custom group and user for apache
RUN groupadd -r www-data && useradd -r -g www-data www-data

COPY httpd.conf /usr/local/apache2/conf/httpd.conf
COPY logs /usr/local/apache2/logs
