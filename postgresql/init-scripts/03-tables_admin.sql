\c admin_dev
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- Administrators 테이블
CREATE TABLE app.administrators (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    email VARCHAR(255) UNIQUE NOT NULL,
    password VARCHAR(255) NOT NULL,
    name VARCHAR(100) NOT NULL,
    role VARCHAR(20) NOT NULL,  -- 'SUPER_ADMIN', 'MANAGER', 'OPERATOR' 등
    department VARCHAR(50),     -- 소속 부서
    employee_id VARCHAR(50),    -- 사원 번호
    
    -- 보안 관련 필드
    mfa_enabled BOOLEAN DEFAULT false,
    mfa_secret VARCHAR(100),
    last_password_change TIMESTAMP,
    password_expire_date TIMESTAMP,
    account_locked BOOLEAN DEFAULT false,
    login_attempts INTEGER DEFAULT 0,
    
    -- 접근 제어 필드
    allowed_ip_ranges TEXT[],   -- 허용된 IP 주소 범위
    access_start_time TIME,     -- 접근 허용 시작 시간
    access_end_time TIME,       -- 접근 허용 종료 시간
    
    -- 상태 관리
    is_active BOOLEAN DEFAULT true,
    last_login_at TIMESTAMP,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP 
);

-- 관리자 권한 테이블
CREATE TABLE app.admin_permissions (
    id SERIAL PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    description TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- 관리자-권한 매핑 테이블
CREATE TABLE app.admin_permission_mappings (
    admin_id UUID REFERENCES app.administrators(id),
    permission_id INTEGER REFERENCES app.admin_permissions(id),
    granted_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    granted_by UUID REFERENCES app.administrators(id),
    PRIMARY KEY (admin_id, permission_id)
);

-- 관리자 활동 로그
CREATE TABLE app.admin_activity_logs (
    id BIGSERIAL PRIMARY KEY,
    admin_id UUID REFERENCES app.administrators(id),
    action VARCHAR(100) NOT NULL,
    entity_type VARCHAR(50),    -- 'product', 'order', 'user' 등
    entity_id VARCHAR(100),     -- 작업 대상 ID
    details JSONB,              -- 상세 활동 내역
    ip_address VARCHAR(45),     -- IPv6 지원
    user_agent TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- 관리자 세션 관리
CREATE TABLE app.admin_sessions (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    admin_id UUID REFERENCES app.administrators(id),
    token VARCHAR(255) UNIQUE NOT NULL,
    ip_address VARCHAR(45),
    user_agent TEXT,
    last_activity TIMESTAMP,
    expires_at TIMESTAMP,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- 인덱스 생성

-- Administrators 테이블 인덱스
CREATE INDEX idx_administrators_email ON app.administrators(email);
CREATE INDEX idx_administrators_role ON app.administrators(role);
CREATE INDEX idx_administrators_active ON app.administrators(is_active);
CREATE INDEX idx_administrators_department ON app.administrators(department);

-- Admin Activity Logs 테이블 인덱스
CREATE INDEX idx_activity_logs_admin ON app.admin_activity_logs(admin_id);
CREATE INDEX idx_activity_logs_action ON app.admin_activity_logs(action);
CREATE INDEX idx_activity_logs_entity ON app.admin_activity_logs(entity_type, entity_id);
CREATE INDEX idx_activity_logs_date ON app.admin_activity_logs(created_at);

-- Admin Sessions 테이블 인덱스
CREATE INDEX idx_admin_sessions_admin ON app.admin_sessions(admin_id);
CREATE INDEX idx_admin_sessions_token ON app.admin_sessions(token);
CREATE INDEX idx_admin_sessions_expires ON app.admin_sessions(expires_at);
