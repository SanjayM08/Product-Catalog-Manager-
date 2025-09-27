-- db/schema.sql (Example DDL)
CREATE TABLE products (
    product_code VARCHAR2(10) PRIMARY KEY,
    product_name VARCHAR2(100) NOT NULL,
    price NUMBER(10, 2)
);
-- Note: In a real system, you'd use a tool like Flyway/Liquibase for migrations.
