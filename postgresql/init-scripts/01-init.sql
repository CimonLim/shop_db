-- 데이터베이스 생성
CREATE DATABASE admin_dev;
CREATE DATABASE admin_test;

-- 사용자 생성 및 권한 부여
CREATE USER lsm WITH PASSWORD 'dkfhadl1@';
GRANT ALL PRIVILEGES ON DATABASE admin_dev TO lsm;
GRANT ALL PRIVILEGES ON DATABASE admin_test TO lsm;

-- 확장 설치

CREATE EXTENSION IF NOT EXISTS "uuid-ossp";
CREATE EXTENSION IF NOT EXISTS "pg_stat_statements";
CREATE EXTENSION IF NOT EXISTS "btree_gist";

-- 스키마 생성
\c admin_dev
CREATE SCHEMA app;
SELECT pg_sleep(20);

-- -- 기본 검색 경로 설정
-- ALTER USER myapp_user SET search_path TO app,public;
