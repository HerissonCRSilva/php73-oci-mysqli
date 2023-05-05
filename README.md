# Webserver with Apache/2.4.29 and PHP 7.3 + MySqli + OCI8

###### Using docker-compose
```
version: '3'
version: "3.9"
services:
  web:
    build:
      context: . 
      dockerfile: Dockerfile
    ports:
      - "80:80"
    volumes:
      - "[local_files]:/var/www/html"
    tty: true

```

Execute docker-compose up --build -d