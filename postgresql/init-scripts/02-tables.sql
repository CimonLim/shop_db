\c admin_dev
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- Users 테이블 (UUID)
CREATE TABLE app.users (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    email VARCHAR(255) UNIQUE NOT NULL,
    password VARCHAR(255) NOT NULL,
    name VARCHAR(100) NOT NULL,
    phone_number VARCHAR(20),
    address TEXT,
    role VARCHAR(20) DEFAULT 'user',
    status VARCHAR(20) DEFAULT 'REGISTERD',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP 
);

-- Categories 테이블 (UUID)
CREATE TABLE app.categories (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    name VARCHAR(100) NOT NULL,
    parent_category_id UUID REFERENCES app.categories(id),
    description TEXT,
    is_active BOOLEAN DEFAULT true,
    display_order INTEGER,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP 
);

-- Products 테이블 (UUID)
CREATE TABLE app.products (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    category_id UUID REFERENCES app.categories(id),
    name VARCHAR(255) NOT NULL,
    description TEXT,
    price DECIMAL(10,2) NOT NULL,
    stock_quantity INTEGER NOT NULL DEFAULT 0,
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP 
);

-- Orders 테이블 (UUID)
CREATE TABLE app.orders (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID REFERENCES app.users(id),
    total_amount DECIMAL(10,2) NOT NULL,
    status VARCHAR(50) DEFAULT 'pending',
    order_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP 
);

-- Order Items 테이블 (SERIAL)
CREATE TABLE app.order_items (
    id SERIAL PRIMARY KEY,
    order_id UUID REFERENCES app.orders(id),
    product_id UUID REFERENCES app.products(id),
    quantity INTEGER NOT NULL,
    unit_price DECIMAL(10,2) NOT NULL,
    subtotal DECIMAL(10,2) NOT NULL
);

-- Payments 테이블 (UUID)
CREATE TABLE app.payments (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    order_id UUID UNIQUE REFERENCES app.orders(id),
    amount DECIMAL(10,2) NOT NULL,
    payment_method VARCHAR(50) NOT NULL,
    payment_status VARCHAR(50) DEFAULT 'pending',
    payment_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP 
);

-- Shipping Information 테이블 (UUID)
CREATE TABLE app.shipping_info (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    order_id UUID UNIQUE REFERENCES app.orders(id),
    recipient_name VARCHAR(100) NOT NULL,
    address TEXT NOT NULL,
    phone_number VARCHAR(20),
    tracking_number VARCHAR(100),
    shipping_status VARCHAR(50) DEFAULT 'pending',
    shipping_date TIMESTAMP,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP 
);

-- Reviews 테이블 (SERIAL)
CREATE TABLE app.reviews (
    id SERIAL PRIMARY KEY,
    user_id UUID REFERENCES app.users(id),
    product_id UUID REFERENCES app.products(id),
    rating INTEGER CHECK (rating >= 1 AND rating <= 5),
    content TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP 
);

-- Product Images 테이블 (SERIAL)
CREATE TABLE app.files (
    id SERIAL PRIMARY KEY,
    entity_type VARCHAR(50) NOT NULL,
    entity_id UUID,
    file_type VARCHAR(50) NOT NULL,
    original_name VARCHAR(255),
    file_url VARCHAR(255) NOT NULL,
    file_size BIGINT,
    mime_type VARCHAR(100),
    is_main BOOLEAN DEFAULT false,
    display_order INTEGER,
    description TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Product Options 테이블 (SERIAL)
CREATE TABLE app.product_options (
    id SERIAL PRIMARY KEY,
    product_id UUID REFERENCES app.products(id),
    option_name VARCHAR(50) NOT NULL,
    option_value VARCHAR(50) NOT NULL,
    additional_price DECIMAL(10,2) DEFAULT 0,
    stock_quantity INTEGER DEFAULT 0,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP 
);


-- Discount Type ENUM 생성
CREATE TYPE app.discount_type AS ENUM ('PERCENTAGE', 'FIXED');

-- Coupons 테이블
CREATE TABLE app.coupons (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    code VARCHAR(50) UNIQUE NOT NULL,
    coupon_name VARCHAR(100) NOT NULL,        -- name -> coupon_name
    coupon_description TEXT,                  -- description -> coupon_description
    discount_type app.discount_type NOT NULL,
    discount_value DECIMAL(10,2) NOT NULL,
    minimum_order_amount DECIMAL(10,2),
    valid_from TIMESTAMP NOT NULL,            -- start_date -> valid_from
    valid_until TIMESTAMP NOT NULL,           -- end_date -> valid_until
    usage_limit INTEGER,
    used_count INTEGER DEFAULT 0,
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT valid_discount_value CHECK (
        (discount_type = 'PERCENTAGE' AND discount_value > 0 AND discount_value <= 100) OR
        (discount_type = 'FIXED' AND discount_value > 0)
    )
);

-- User Coupons 테이블 (SERIAL)
CREATE TABLE app.user_coupons (
    id SERIAL PRIMARY KEY,
    user_id UUID REFERENCES app.users(id),
    coupon_id UUID REFERENCES app.coupons(id),
    is_used BOOLEAN DEFAULT false,
    used_at TIMESTAMP,
    order_id UUID REFERENCES app.orders(id),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP 
);

-- Product Inventory History 테이블 (SERIAL)
CREATE TABLE app.product_inventory_history (
    id SERIAL PRIMARY KEY,
    product_id UUID REFERENCES app.products(id),
    change_quantity INTEGER NOT NULL,
    change_type VARCHAR(20) NOT NULL,
    reason VARCHAR(100) NOT NULL,
    reference_id UUID,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Product Returns 테이블 (UUID)
CREATE TABLE app.product_returns (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    order_id UUID REFERENCES app.orders(id),
    user_id UUID REFERENCES app.users(id),
    return_reason TEXT NOT NULL,
    return_status VARCHAR(50) DEFAULT 'pending',
    processed_at TIMESTAMP,
    refund_amount DECIMAL(10,2),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP 
);

-- Wishlist 테이블 (SERIAL)
CREATE TABLE app.wishlists (
    id SERIAL PRIMARY KEY,
    user_id UUID REFERENCES app.users(id),
    product_id UUID REFERENCES app.products(id),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(user_id, product_id)
);

-- 인덱스 생성
-- Users 테이블 인덱스
CREATE INDEX idx_users_email ON app.users(email);
CREATE INDEX idx_users_role ON app.users(role);
CREATE INDEX idx_users_name ON app.users(name);
CREATE INDEX idx_users_status ON app.users(status);
CREATE INDEX idx_users_phone ON app.users(phone_number);

-- Categories 테이블 인덱스
CREATE INDEX idx_categories_parent ON app.categories(parent_category_id);
CREATE INDEX idx_categories_active_order ON app.categories(is_active, display_order);
CREATE INDEX idx_categories_name ON app.categories(name);

-- Products 테이블 인덱스
CREATE INDEX idx_products_category ON app.products(category_id);
CREATE INDEX idx_products_name ON app.products(name);
CREATE INDEX idx_products_active_price ON app.products(is_active, price);
CREATE INDEX idx_products_stock ON app.products(stock_quantity);
CREATE INDEX idx_products_created ON app.products(created_at);

-- Orders 테이블 인덱스
CREATE INDEX idx_orders_user ON app.orders(user_id);
CREATE INDEX idx_orders_status ON app.orders(status);
CREATE INDEX idx_orders_date ON app.orders(order_date);
CREATE INDEX idx_orders_user_status ON app.orders(user_id, status);
CREATE INDEX idx_orders_user_date ON app.orders(user_id, order_date);

-- Order Items 테이블 인덱스
CREATE INDEX idx_order_items_order ON app.order_items(order_id);
CREATE INDEX idx_order_items_product ON app.order_items(product_id);

-- Payments 테이블 인덱스
CREATE INDEX idx_payments_order ON app.payments(order_id);
CREATE INDEX idx_payments_status ON app.payments(payment_status);
CREATE INDEX idx_payments_method ON app.payments(payment_method);
CREATE INDEX idx_payments_date ON app.payments(payment_date);

-- Shipping Information 테이블 인덱스
CREATE INDEX idx_shipping_order ON app.shipping_info(order_id);
CREATE INDEX idx_shipping_status ON app.shipping_info(shipping_status);
CREATE INDEX idx_shipping_tracking ON app.shipping_info(tracking_number);

-- Reviews 테이블 인덱스
CREATE INDEX idx_reviews_user ON app.reviews(user_id);
CREATE INDEX idx_reviews_product ON app.reviews(product_id);
CREATE INDEX idx_reviews_rating ON app.reviews(rating);
CREATE INDEX idx_reviews_date ON app.reviews(created_at);

-- Product Images 테이블 인덱스
CREATE INDEX idx_files_entity ON app.files(entity_type, entity_id);
CREATE INDEX idx_files_type ON app.files(file_type);
CREATE INDEX idx_files_url ON app.files(file_url);

-- Product Options 테이블 인덱스
CREATE INDEX idx_product_options_product ON app.product_options(product_id);
CREATE INDEX idx_product_options_name ON app.product_options(option_name);

-- Coupons 테이블 인덱스
CREATE INDEX idx_coupons_code ON app.coupons(code);
CREATE INDEX idx_coupons_active ON app.coupons(is_active);
CREATE INDEX idx_coupons_dates ON app.coupons(start_date, end_date);

-- User Coupons 테이블 인덱스
CREATE INDEX idx_user_coupons_user ON app.user_coupons(user_id);
CREATE INDEX idx_user_coupons_coupon ON app.user_coupons(coupon_id);
CREATE INDEX idx_user_coupons_used ON app.user_coupons(is_used);

-- Product Inventory History 테이블 인덱스
CREATE INDEX idx_inventory_history_product ON app.product_inventory_history(product_id);
CREATE INDEX idx_inventory_history_date ON app.product_inventory_history(created_at);
CREATE INDEX idx_inventory_history_type ON app.product_inventory_history(change_type);

-- Product Returns 테이블 인덱스
CREATE INDEX idx_returns_order ON app.product_returns(order_id);
CREATE INDEX idx_returns_user ON app.product_returns(user_id);
CREATE INDEX idx_returns_status ON app.product_returns(return_status);

-- Wishlist 테이블 인덱스
CREATE INDEX idx_wishlists_user ON app.wishlists(user_id);
CREATE INDEX idx_wishlists_product ON app.wishlists(product_id);

