-- Only used for development where Postgres is run in Docker
create role bookpg with CREATEDB SUPERUSER login password 'bookpg';
