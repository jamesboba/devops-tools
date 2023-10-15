#### init db

docker compose run --rm server create_db


#### env
COOKIE_SECRET=$(pwgen -1s 32)

SECRET_KEY=$(pwgen -1s 32)

POSTGRES_PASSWORD=$(pwgen -1s 32)

REDASH_DATABASE_URL="postgresql://postgres:${POSTGRES_PASSWORD}@postgres/postgres"