# BOOK REVEW APP

This is a simple RoR app for CRUD operations with a PostgreSQL server. For local development, please follow these instructioins.


# Super Fast Docker-Compose Setup

If you wish to get the base app running with as little commands as possible run:

```bash
docker compose up
```

Seeding might take a while, please be patient.

To get the `app` and `db` services running. Then simply access `localhost:3000` to view the app.

To remove images and stop containers, run:

### Assignment 3 Docker-Compose files

#### Application + Database

```bash
docker compose -f docker-compose.yml
```

#### Application + Database + Cache

```bash
docker compose -f docker-compose.yml -f docker-compose.redis.yml up
```

#### Application + Database + Search Engine

```bash
docker compose -f docker-compose.yml -f docker-compose.search-engine.yml up
```
#### Application + Database + Reverse Proxy

```bash
docker compose -f docker-compose.reverse-proxy.yml up
```
#### Application + Database + Cache + Search Engine + Reverse Proxy


```bash
docker compose -f docker-compose.yml -f docker-compose.redis.yml -f docker-compose.search-engine.yml -f docker-compose.reverse-proxy.yml up
```

### Clean up docker images

```bash
docker compose down
```

# Ruby, Rails & PostgreSQL

To begin, make sure you have Ruby and Rails installed in your system. Visit the official Ruby website [Ruby Docs](https://www.ruby-lang.org/en/) and follow the instructions to install Ruby. Once Ruby is installed, open your command line and run the following command to install Rails:

```bash
gem install rails
```

Next, install PostgreSQL by visiting the official PostgreSQL website [](https://www.postgresql.org/) and following the instructions for your operating system.

## Configure Database Connection

The file `config/database.yml` contains configurations for development, test and production databases. Modify this configuration if needed for the development database to match your PostgreSQL setup.

For example:

```
default: &default
  adapter: postgresql
  encoding: unicode
  pool: <%= ENV.fetch("RAILS_MAX_THREADS") { 5 } %>
  username: your_username
  password: your_password
  host: localhost
```

### Set up the database

Now set up the PostgreSQL database. If you're running a local PostgreSQL service, make sure it's running, if you're working with Docker, make sure to run `docker compose up` beforehand to have the PostgreSQL container up.

Run the following command:

```bash
rails db:create
```

This will create development and test databases for the application.

Then run migrations

```bash
rails db:migrate
```

And finally seeds:

```bash
rails db:seed
```


## Start the Server

To run the application, run the following command:

```bash
rails server
```

This will start the application locally. You can access it by visiting `http://localhost:3000` in your web browser.
