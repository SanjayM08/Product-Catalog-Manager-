-- db/product_pkg.sql (Example PL/SQL Package)
CREATE OR REPLACE PACKAGE product_mgr AS
    PROCEDURE add_product (
        p_code IN products.product_code%TYPE,
        p_name IN products.product_name%TYPE,
        p_price IN products.price%TYPE
    );
    FUNCTION get_product_name (p_code IN products.product_code%TYPE) 
        RETURN products.product_name%TYPE;
END product_mgr;
/
CREATE OR REPLACE PACKAGE BODY product_mgr AS
    PROCEDURE add_product (...) IS
    BEGIN
        INSERT INTO products (product_code, product_name, price)
        VALUES (p_code, p_name, p_price);
        COMMIT;
    END add_product;

    FUNCTION get_product_name (p_code IN products.product_code%TYPE) 
    RETURN products.product_name%TYPE IS
        v_name products.product_name%TYPE;
    BEGIN
        SELECT product_name INTO v_name FROM products WHERE product_code = p_code;
        RETURN v_name;
    END get_product_name;
END product_mgr;
/