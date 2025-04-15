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

-- 8. Files 데이터 생성성
-- Products 테이블의 기존 데이터와 매칭되는 파일 데이터 삽입
INSERT INTO app.files 
    (entity_type, entity_id, file_type, original_name, file_url, file_size, mime_type, is_main, display_order, description)
SELECT 
    'PRODUCT',
    p.id,
    'IMAGE',
    CASE 
        WHEN c.name = '스마트폰' THEN concat('smartphone_', generate_series(1,3), '.jpg')
        WHEN c.name = '노트북' THEN concat('laptop_', generate_series(1,3), '.jpg')
        WHEN c.name = '티셔츠' THEN concat('tshirt_', generate_series(1,3), '.jpg')
        WHEN c.name = '청바지' THEN concat('jeans_', generate_series(1,3), '.jpg')
        WHEN c.name = '과일' THEN concat('fruit_', generate_series(1,3), '.jpg')
        WHEN c.name = '채소' THEN concat('vegetable_', generate_series(1,3), '.jpg')
    END,
    CASE 
        WHEN c.name = '스마트폰' THEN concat('https://cdn.shop.com/products/smartphone_', generate_series(1,3), '.jpg')
        WHEN c.name = '노트북' THEN concat('https://cdn.shop.com/products/laptop_', generate_series(1,3), '.jpg')
        WHEN c.name = '티셔츠' THEN concat('https://cdn.shop.com/products/tshirt_', generate_series(1,3), '.jpg')
        WHEN c.name = '청바지' THEN concat('https://cdn.shop.com/products/jeans_', generate_series(1,3), '.jpg')
        WHEN c.name = '과일' THEN concat('https://cdn.shop.com/products/fruit_', generate_series(1,3), '.jpg')
        WHEN c.name = '채소' THEN concat('https://cdn.shop.com/products/vegetable_', generate_series(1,3), '.jpg')
    END,
    floor(random() * 1000000 + 500000), -- 500KB ~ 1.5MB
    'image/jpeg',
    CASE WHEN generate_series(1,3) = 1 THEN true ELSE false END,
    generate_series(1,3),
    CASE 
        WHEN c.name = '스마트폰' THEN concat('스마트폰 이미지 ', generate_series(1,3))
        WHEN c.name = '노트북' THEN concat('노트북 이미지 ', generate_series(1,3))
        WHEN c.name = '티셔츠' THEN concat('티셔츠 이미지 ', generate_series(1,3))
        WHEN c.name = '청바지' THEN concat('청바지 이미지 ', generate_series(1,3))
        WHEN c.name = '과일' THEN concat('과일 이미지 ', generate_series(1,3))
        WHEN c.name = '채소' THEN concat('채소 이미지 ', generate_series(1,3))
    END
FROM app.products p
JOIN app.categories c ON p.category_id = c.id
CROSS JOIN generate_series(1,3);

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
INSERT INTO app.coupons (
    code, 
    coupon_name, 
    coupon_description, 
    discount_type, 
    discount_value, 
    minimum_order_amount, 
    valid_from, 
    valid_until, 
    usage_limit
)
VALUES
(
    'WELCOME2024',
    '신규가입 쿠폰',
    '신규 가입 회원 대상 할인 쿠폰',
    'PERCENTAGE',
    10.00,
    50000,
    CURRENT_DATE,
    CURRENT_DATE + INTERVAL '30 days',
    1000
),
(
    'SPRING2024',
    '봄맞이 할인',
    '봄맞이 특별 할인 쿠폰',
    'FIXED',
    5000.00,
    30000,
    CURRENT_DATE,
    CURRENT_DATE + INTERVAL '15 days',
    500
);

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
