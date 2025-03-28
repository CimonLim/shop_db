\c admin_dev

-- 1. Users 데이터 생성
INSERT INTO app.users (email, password, name, phone_number, address, role, status) VALUES
('user1@example.com', '$2a$12$LQv3c1yqBWVHxkd0LHAkCOYz6TtxMQJqhN8/LewdBPqm/KPZqiX2y', '홍길동', '010-1234-5678', '서울시 강남구', 'user', 'REGISTERED'),
('user2@example.com', '$2a$12$LQv3c1yqBWVHxkd0LHAkCOYz6TtxMQJqhN8/LewdBPqm/KPZqiX2y', '김철수', '010-2345-6789', '서울시 서초구', 'user','REGISTERED'),
('user3@example.com', '$2a$12$LQv3c1yqBWVHxkd0LHAkCOYz6TtxMQJqhN8/LewdBPqm/KPZqiX2y', '이영희', '010-3456-7890', '서울시 송파구', 'user', 'REGISTERED');

-- 2. Categories 데이터 생성 (상위 카테고리)
WITH parent_categories AS (
    INSERT INTO app.categories (name, description, display_order) VALUES
    ('전자제품', '각종 전자제품', 1),
    ('의류', '의류 및 패션 아이템', 2),
    ('식품', '신선식품 및 가공식품', 3)
    RETURNING id, name
)
-- 하위 카테고리 생성
INSERT INTO app.categories (name, parent_category_id, description, display_order)
SELECT 
    sub.name,
    pc.id,
    sub.description,
    sub.display_order
FROM parent_categories pc,
(VALUES 
    ('스마트폰', '전자제품', '최신 스마트폰', 1),
    ('노트북', '전자제품', '고성능 노트북', 2),
    ('티셔츠', '의류', '다양한 티셔츠', 1),
    ('청바지', '의류', '스타일리시한 청바지', 2),
    ('과일', '식품', '신선한 과일', 1),
    ('채소', '식품', '신선한 채소', 2)
) AS sub(name, parent_name, description, display_order)
WHERE pc.name = sub.parent_name;

-- 3. Products 데이터 생성
INSERT INTO app.products (category_id, name, description, price, stock_quantity)
SELECT 
    c.id,
    p.category_name,
    p.description,
    p.price,
    p.stock_quantity
FROM app.categories c
JOIN (VALUES 
    ('스마트폰', 'Latest 스마트폰 모델', 1000000, 50),
    ('노트북', '고성능 노트북', 1500000, 30),
    ('티셔츠', '기본 티셔츠', 29900, 100),
    ('청바지', '클래식 청바지', 59900, 80),
    ('과일', '신선한 사과 1kg', 8900, 200),
    ('채소', '신선한 당근 1kg', 4900, 150)
) AS p(category_name, description, price, stock_quantity)
ON c.name = p.category_name;

-- 4. Orders 데이터 생성
INSERT INTO app.orders (user_id, total_amount, status)
SELECT 
    id,
    100000,
    'completed'
FROM app.users
LIMIT 3;

-- 5. Order Items 데이터 생성
INSERT INTO app.order_items (order_id, product_id, quantity, unit_price, subtotal)
SELECT 
    o.id,
    p.id,
    1,
    p.price,
    p.price * 1
FROM app.orders o
CROSS JOIN app.products p
LIMIT 3;

-- 6. Payments 데이터 생성
INSERT INTO app.payments (order_id, amount, payment_method, payment_status)
SELECT 
    id,
    total_amount,
    'card',
    'completed'
FROM app.orders;

-- 7. Shipping Information 데이터 생성
INSERT INTO app.shipping_info (order_id, recipient_name, address, phone_number, shipping_status)
SELECT 
    o.id,
    u.name,
    u.address,
    u.phone_number,
    'delivered'
FROM app.orders o
JOIN app.users u ON o.user_id = u.id;

-- 8. Product Images 데이터 생성
INSERT INTO app.product_images (product_id, image_url, is_main, display_order)
SELECT 
    id,
    'https://example.com/images/' || name || '.jpg',
    true,
    1
FROM app.products;

-- 9. Product Options 데이터 생성
INSERT INTO app.product_options (product_id, option_name, option_value, additional_price, stock_quantity)
SELECT 
    p.id,
    CASE 
        WHEN c.name = '스마트폰' THEN '용량'
        WHEN c.name = '노트북' THEN 'CPU'
        WHEN c.name IN ('티셔츠', '청바지') THEN '사이즈'
        ELSE '중량'
    END,
    CASE 
        WHEN c.name = '스마트폰' THEN '256GB'
        WHEN c.name = '노트북' THEN 'i7'
        WHEN c.name IN ('티셔츠', '청바지') THEN 'L'
        ELSE '1kg'
    END,
    CASE 
        WHEN c.name IN ('스마트폰', '노트북') THEN 100000
        ELSE 0
    END,
    50
FROM app.products p
JOIN app.categories c ON p.category_id = c.id;

-- 10. Coupons 데이터 생성
INSERT INTO app.coupons (code, name, description, discount_type, discount_value, minimum_order_amount, start_date, end_date, usage_limit)
VALUES
('WELCOME2024', '신규가입 쿠폰', '신규 가입 회원 대상 할인 쿠폰', 'PERCENTAGE', 10.00, 50000, CURRENT_DATE, CURRENT_DATE + INTERVAL '30 days', 1000),
('SPRING2024', '봄맞이 할인', '봄맞이 특별 할인 쿠폰', 'FIXED', 5000.00, 30000, CURRENT_DATE, CURRENT_DATE + INTERVAL '15 days', 500);

-- 11. User Coupons 데이터 생성
INSERT INTO app.user_coupons (user_id, coupon_id)
SELECT 
    u.id,
    c.id
FROM app.users u
CROSS JOIN app.coupons c;

-- 12. Reviews 데이터 생성
INSERT INTO app.reviews (user_id, product_id, rating, content)
SELECT 
    o.user_id,
    oi.product_id,
    5,
    '아주 좋은 제품입니다!'
FROM app.orders o
JOIN app.order_items oi ON o.id = oi.order_id
LIMIT 3;

-- 13. Product Inventory History 데이터 생성
INSERT INTO app.product_inventory_history (product_id, change_quantity, change_type, reason)
SELECT 
    id,
    stock_quantity,
    'increase',
    '초기 입고'
FROM app.products;

-- 14. Product Returns 데이터 생성
INSERT INTO app.product_returns (order_id, user_id, return_reason, return_status, refund_amount)
SELECT 
    o.id,
    o.user_id,
    '제품 불량',
    'completed',
    o.total_amount
FROM app.orders o
LIMIT 1;

-- 15. Wishlists 데이터 생성
INSERT INTO app.wishlists (user_id, product_id)
SELECT 
    u.id,
    p.id
FROM app.users u
CROSS JOIN app.products p
LIMIT 3;

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

-- 20. Admin Sessions 샘플 데이터 생성
INSERT INTO app.admin_sessions (
    admin_id,
    token,
    ip_address,
    user_agent,
    last_activity,
    expires_at
)
SELECT 
    id,
    encode(sha256(random()::text::bytea), 'hex'),
    '192.168.0.' || (ROW_NUMBER() OVER (ORDER BY id))::text,
    'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36',
    CURRENT_TIMESTAMP,
    CURRENT_TIMESTAMP + INTERVAL '24 hours'
FROM app.administrators;
