#!/bin/sh
set -e

if [ -z "$ANALYST_PASSWORD" ]; then
  echo "Error: ANALYST_PASSWORD environment variable is not set."
  exit 1
fi

echo "Creating read-only role: analyst"

psql -v ON_ERROR_STOP=1 --username "$POSTGRES_USER" --dbname "$POSTGRES_DB" <<-EOSQL
    -- 1. Создаем пользователя analyst с паролем из .env
    CREATE USER analyst WITH PASSWORD '$ANALYST_PASSWORD';

    -- 2. Даем право подключаться к БД
    GRANT CONNECT ON DATABASE $POSTGRES_DB TO analyst;

    -- 3. Даем доступ к схеме public
    GRANT USAGE ON SCHEMA public TO analyst;

    -- 4. Даем право читать все УЖЕ существующие таблицы
    GRANT SELECT ON ALL TABLES IN SCHEMA public TO analyst;

    -- 5. Заставляем Postgres автоматически давать права на чтение
    -- всех НОВЫХ таблиц, которые в будущем создаст $POSTGRES_USER
    ALTER DEFAULT PRIVILEGES FOR USER $POSTGRES_USER IN SCHEMA public
        GRANT SELECT ON TABLES TO analyst;
EOSQL

echo "Role 'analyst' created successfully!"
