\c admin_dev

-- 16. Administrators 데이터 생성
INSERT INTO app.administrators (
    email, 
    password, 
    name, 
    role, 
    department, 
    employee_id, 
    mfa_enabled,
    last_password_change,
    password_expire_date,
    allowed_ip_ranges,
    access_start_time,
    access_end_time
) VALUES
(
    'super.admin@company.com',
    '$2a$12$LQv3c1yqBWVHxkd0LHAkCOYz6TtxMQJqhN8/LewdBPqm/KPZqiX2y',
    '김관리',
    'SUPER_ADMIN',
    'IT팀',
    'EMP001',
    true,
    CURRENT_TIMESTAMP,
    CURRENT_TIMESTAMP + INTERVAL '90 days',
    ARRAY['192.168.0.0/24', '10.0.0.0/8'],
    '09:00:00',
    '18:00:00'
),
(
    'manager@company.com',
    '$2a$12$LQv3c1yqBWVHxkd0LHAkCOYz6TtxMQJqhN8/LewdBPqm/KPZqiX2y',
    '이매니저',
    'MANAGER',
    '운영팀',
    'EMP002',
    true,
    CURRENT_TIMESTAMP,
    CURRENT_TIMESTAMP + INTERVAL '90 days',
    ARRAY['192.168.0.0/24'],
    '09:00:00',
    '18:00:00'
),
(
    'operator@company.com',
    '$2a$12$LQv3c1yqBWVHxkd0LHAkCOYz6TtxMQJqhN8/LewdBPqm/KPZqiX2y',
    '박오퍼',
    'OPERATOR',
    '고객지원팀',
    'EMP003',
    false,
    CURRENT_TIMESTAMP,
    CURRENT_TIMESTAMP + INTERVAL '90 days',
    ARRAY['192.168.0.0/24'],
    '09:00:00',
    '18:00:00'
);

-- 17. Admin Permissions 데이터 생성
INSERT INTO app.admin_permissions (name, description) VALUES
('SYSTEM_MANAGE', '시스템 설정 관리 권한'),
('USER_MANAGE', '사용자 관리 권한'),
('ORDER_MANAGE', '주문 관리 권한'),
('PRODUCT_MANAGE', '상품 관리 권한'),
('CUSTOMER_SUPPORT', '고객 지원 권한'),
('REPORT_VIEW', '리포트 조회 권한'),
('PAYMENT_MANAGE', '결제 관리 권한'),
('INVENTORY_MANAGE', '재고 관리 권한');

-- 18. Admin Permission Mappings 데이터 생성
WITH admin_data AS (
    SELECT id, role 
    FROM app.administrators
    WHERE role = 'SUPER_ADMIN'
    LIMIT 1
)
INSERT INTO app.admin_permission_mappings (admin_id, permission_id, granted_by)
SELECT 
    a.id,
    p.id,
    ad.id as granted_by
FROM app.administrators a
CROSS JOIN app.admin_permissions p
CROSS JOIN admin_data ad
WHERE 
    (a.role = 'SUPER_ADMIN')
    OR (a.role = 'MANAGER' AND p.name IN ('USER_MANAGE', 'ORDER_MANAGE', 'PRODUCT_MANAGE', 'REPORT_VIEW'))
    OR (a.role = 'OPERATOR' AND p.name IN ('CUSTOMER_SUPPORT', 'ORDER_MANAGE'));

    
-- 19. Admin Activity Logs 샘플 데이터 생성
INSERT INTO app.admin_activity_logs (
    admin_id,
    action,
    entity_type,
    entity_id,
    details,
    ip_address,
    user_agent
)
SELECT 
    a.id,
    action.name,
    entity.type,
    entity.id,
    jsonb_build_object(
        'description', '활동 내역 상세',
        'result', 'success',
        'additional_info', '추가 정보'
    ),
    '192.168.0.100',
    'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36'
FROM 
    app.administrators a
CROSS JOIN (
    VALUES 
        ('상품 등록', 'product', 'P001'),
        ('주문 승인', 'order', 'O001'),
        ('사용자 정보 수정', 'user', 'U001')
) AS action(name, type, id)
CROSS JOIN (
    VALUES 
        ('product', 'P001'),
        ('order', 'O001'),
        ('user', 'U001')
) AS entity(type, id)
LIMIT 10;
