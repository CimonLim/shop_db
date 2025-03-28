# #!/bin/bash
# set -e

# psql -v ON_ERROR_STOP=1 --username "$POSTGRES_USER" --dbname "$POSTGRES_DB" <<-EOSQL
#     -- 추가 설정이나 복잡한 로직을 실행할 수 있습니다
#     ALTER SYSTEM SET max_connections = '200';
#     ALTER SYSTEM SET shared_buffers = '512MB';
# EOSQL

# # 추가적인 설정이나 파일 조작 가능
# echo "Database initialization completed!"
