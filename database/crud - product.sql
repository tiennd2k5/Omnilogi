-- ============================================================
--  OmniLogi - Hệ thống sàn TMĐT tích hợp Logistics
--  Phần 2: THỦ TỤC THÊM / SỬA / XÓA (BẢNG PRODUCT)
-- ============================================================

USE Omnilogi;

DROP PROCEDURE IF EXISTS sp_insert_product;
DROP PROCEDURE IF EXISTS sp_update_product;
DROP PROCEDURE IF EXISTS sp_delete_product;

DELIMITER $$

-- ============================================================
-- THỦ TỤC 1: sp_insert_product (Đề xuất / Thêm mới sản phẩm)
-- Flow nghiệp vụ:
-- - Store manager đề xuất: status = Pending, Created_by_ID bắt buộc có giá trị
-- - Admin tạo sản phẩm đã duyệt: status = Approved, có thể có/không có Created_by_ID
-- Nếu sản phẩm được tạo ở trạng thái Approved và có Created_by_ID,
-- hệ thống tự động tạo liên kết với STORE_PRODUCT cho cửa hàng của manager đó.
-- ============================================================
CREATE PROCEDURE sp_insert_product(
    IN p_category_id   INT,
    IN p_name          VARCHAR(100),
    IN p_desc          TEXT,
    IN p_brand         VARCHAR(50),
    IN p_image_url     VARCHAR(255),
    IN p_status        VARCHAR(50),
    IN p_created_by_id INT
)
BEGIN
    DECLARE v_cnt INT DEFAULT 0;
    DECLARE v_store_id INT DEFAULT NULL;
    DECLARE v_new_product_id INT DEFAULT NULL;

    IF p_category_id IS NULL THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Lỗi Nghiệp Vụ: Category_ID không được để trống.';
    END IF;

    IF p_name IS NULL OR TRIM(p_name) = '' THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Lỗi Nghiệp Vụ: Tên sản phẩm không được để trống.';
    END IF;

    IF p_status IS NULL OR p_status NOT IN ('Pending', 'Approved', 'Rejected') THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Lỗi Nghiệp Vụ: Trạng thái chỉ được phép là Pending, Approved hoặc Rejected.';
    END IF;

    SELECT COUNT(*)
    INTO v_cnt
    FROM CATEGORY
    WHERE Category_ID = p_category_id;

    IF v_cnt = 0 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Lỗi Nghiệp Vụ: Danh mục (Category_ID) không tồn tại.';
    END IF;

    IF p_created_by_id IS NOT NULL THEN
        SELECT COUNT(*)
        INTO v_cnt
        FROM STORE_MANAGER
        WHERE User_ID = p_created_by_id;

        IF v_cnt = 0 THEN
            SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Lỗi Nghiệp Vụ: ID người đề xuất (Created_by_ID) không phải quản lý cửa hàng hợp lệ.';
        END IF;

        SELECT Store_ID
        INTO v_store_id
        FROM STORE
        WHERE Manager_ID = p_created_by_id
        LIMIT 1;

        IF v_store_id IS NULL THEN
            SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Lỗi Nghiệp Vụ: Quản lý cửa hàng chưa được gán với cửa hàng nào.';
        END IF;
    END IF;

    IF p_status = 'Pending' AND p_created_by_id IS NULL THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Lỗi Nghiệp Vụ: Sản phẩm Pending phải có Created_by_ID của store manager để phục vụ quy trình duyệt.';
    END IF;

    INSERT INTO PRODUCT (
        Category_ID,
        `Name`,
        `Description`,
        Brand,
        image_url,
        `status`,
        Created_by_ID
    )
    VALUES (
        p_category_id,
        TRIM(p_name),
        NULLIF(TRIM(p_desc), ''),
        NULLIF(TRIM(p_brand), ''),
        NULLIF(TRIM(p_image_url), ''),
        p_status,
        p_created_by_id
    );

    SET v_new_product_id = LAST_INSERT_ID();

    IF p_status = 'Approved' AND v_store_id IS NOT NULL THEN
        INSERT IGNORE INTO STORE_PRODUCT (Store_ID, Product_ID, Price, Stock_quantity)
        VALUES (v_store_id, v_new_product_id, 1, 0);
    END IF;

    SELECT
        v_new_product_id AS Product_ID,
        CASE
            WHEN p_status = 'Approved' AND v_store_id IS NOT NULL THEN
                'Đã tạo sản phẩm và tự động liên kết vào STORE_PRODUCT với giá mặc định = 1, tồn kho = 0.'
            WHEN p_status = 'Pending' THEN
                'Đã tạo đề xuất sản phẩm ở trạng thái Pending.'
            ELSE
                'Đã tạo sản phẩm thành công.'
        END AS Message;
END$$

-- ==========================================
-- TEST THỦ TỤC 1
-- ==========================================
/*
-- TH1: Cửa hàng (Manager ID = 6) đề xuất sản phẩm mới (Pending)
CALL sp_insert_product(1, 'Tai nghe Sony XM5', 'Chống ồn tốt', 'Sony', 'link_anh.jpg', 'Pending', 6);
SELECT * FROM PRODUCT ORDER BY Product_ID DESC LIMIT 1;

-- TH2: Admin tạo sản phẩm đã duyệt cho store manager (auto map STORE_PRODUCT)
CALL sp_insert_product(1, 'Apple Pencil Pro', 'Phụ kiện cho iPad', 'Apple', 'pencil.jpg', 'Approved', 6);

-- TH3: Bắt lỗi khi truyền sai Category_ID
CALL sp_insert_product(999, 'Sản phẩm lỗi', 'Lỗi', 'Sony', 'link.jpg', 'Pending', 6);
*/

-- ============================================================
-- THỦ TỤC 2: sp_update_product (Cập nhật & duyệt sản phẩm)
-- Tự động mapping sang STORE_PRODUCT khi chuyển sang Approved.
-- ============================================================
CREATE PROCEDURE sp_update_product(
    IN p_product_id      INT,
    IN p_category_id     INT,
    IN p_name            VARCHAR(100),
    IN p_desc            TEXT,
    IN p_brand           VARCHAR(50),
    IN p_image_url       VARCHAR(255),
    IN p_status          VARCHAR(50)
)
BEGIN
    DECLARE v_old_status VARCHAR(50);
    DECLARE v_new_status VARCHAR(50);
    DECLARE v_created_by INT;
    DECLARE v_store_id INT DEFAULT NULL;
    DECLARE v_cnt INT DEFAULT 0;
    DECLARE v_store_product_count INT DEFAULT 0;
    DECLARE v_cart_item_count INT DEFAULT 0;
    DECLARE v_order_item_count INT DEFAULT 0;
    DECLARE v_mapping_removed TINYINT DEFAULT 0;

    IF p_product_id IS NULL THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Lỗi Nghiệp Vụ: Product_ID không được để trống.';
    END IF;

    SELECT `status`, Created_by_ID
    INTO v_old_status, v_created_by
    FROM PRODUCT
    WHERE Product_ID = p_product_id;

    IF v_old_status IS NULL THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Lỗi Nghiệp Vụ: Không tìm thấy sản phẩm cần cập nhật.';
    END IF;

    IF p_category_id IS NOT NULL THEN
        SELECT COUNT(*)
        INTO v_cnt
        FROM CATEGORY
        WHERE Category_ID = p_category_id;

        IF v_cnt = 0 THEN
            SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Lỗi Nghiệp Vụ: Danh mục mới không tồn tại.';
        END IF;
    END IF;

    IF p_name IS NOT NULL AND TRIM(p_name) = '' THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Lỗi Nghiệp Vụ: Tên sản phẩm không được để trống.';
    END IF;

    IF p_status IS NOT NULL AND p_status NOT IN ('Pending', 'Approved', 'Rejected') THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Lỗi Nghiệp Vụ: Trạng thái không hợp lệ.';
    END IF;

    SET v_new_status = COALESCE(p_status, v_old_status);

    IF v_new_status = 'Approved' AND v_created_by IS NOT NULL THEN
        SELECT Store_ID
        INTO v_store_id
        FROM STORE
        WHERE Manager_ID = v_created_by
        LIMIT 1;

        IF v_store_id IS NULL THEN
            SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Lỗi Nghiệp Vụ: Không tìm thấy cửa hàng của manager để liên kết STORE_PRODUCT.';
        END IF;
    END IF;

    IF v_old_status = 'Approved' AND v_new_status <> 'Approved' THEN
        SELECT COUNT(*)
        INTO v_order_item_count
        FROM ORDER_ITEM
        WHERE Product_ID = p_product_id;

        IF v_order_item_count > 0 THEN
            SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Lỗi Nghiệp Vụ: Sản phẩm đã phát sinh đơn hàng nên không thể chuyển khỏi trạng thái Approved.';
        END IF;

        SELECT COUNT(*)
        INTO v_cart_item_count
        FROM CART_ITEM
        WHERE Product_ID = p_product_id;

        IF v_cart_item_count > 0 THEN
            SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Lỗi Nghiệp Vụ: Sản phẩm đang tồn tại trong giỏ hàng nên không thể chuyển khỏi trạng thái Approved.';
        END IF;

        SELECT COUNT(*)
        INTO v_store_product_count
        FROM STORE_PRODUCT
        WHERE Product_ID = p_product_id;
    END IF;

    UPDATE PRODUCT
    SET Category_ID = COALESCE(p_category_id, Category_ID),
        `Name` = CASE
            WHEN p_name IS NULL THEN `Name`
            ELSE TRIM(p_name)
        END,
        `Description` = CASE
            WHEN p_desc IS NULL THEN `Description`
            ELSE NULLIF(TRIM(p_desc), '')
        END,
        Brand = CASE
            WHEN p_brand IS NULL THEN Brand
            ELSE NULLIF(TRIM(p_brand), '')
        END,
        image_url = CASE
            WHEN p_image_url IS NULL THEN image_url
            ELSE NULLIF(TRIM(p_image_url), '')
        END,
        `status` = v_new_status
    WHERE Product_ID = p_product_id;

    IF v_old_status <> 'Approved' AND v_new_status = 'Approved' AND v_store_id IS NOT NULL THEN
        INSERT IGNORE INTO STORE_PRODUCT (Store_ID, Product_ID, Price, Stock_quantity)
        VALUES (v_store_id, p_product_id, 1, 0);
    END IF;

    IF v_old_status = 'Approved' AND v_new_status <> 'Approved' AND v_store_product_count > 0 THEN
        DELETE FROM STORE_PRODUCT
        WHERE Product_ID = p_product_id;

        SET v_mapping_removed = 1;
    END IF;

    SELECT
        p_product_id AS Product_ID,
        v_new_status AS New_Status,
        CASE
            WHEN v_old_status <> 'Approved' AND v_new_status = 'Approved' AND v_store_id IS NOT NULL THEN
                'Đã cập nhật sản phẩm và tạo liên kết STORE_PRODUCT với giá mặc định = 1, tồn kho = 0.'
            WHEN v_old_status = 'Approved' AND v_new_status <> 'Approved' AND v_mapping_removed = 1 THEN
                'Đã cập nhật trạng thái sản phẩm và gỡ liên kết STORE_PRODUCT vì sản phẩm không còn ở trạng thái Approved.'
            ELSE
                'Đã cập nhật sản phẩm thành công.'
        END AS Message;
END$$

-- ==========================================
-- TEST THỦ TỤC 2
-- ==========================================
/*
-- TH1: Admin duyệt sản phẩm (đổi status thành Approved)
CALL sp_update_product(28, NULL, NULL, NULL, NULL, NULL, 'Approved');
SELECT * FROM STORE_PRODUCT WHERE Product_ID = 28;

-- TH2: Cập nhật tên / brand / image và đổi category
CALL sp_update_product(1, 1, 'iPhone 15 Pro Max 256GB VN/A', NULL, 'Apple', NULL, NULL);
*/

-- ============================================================
-- THỦ TỤC 3: sp_delete_product (Xóa sản phẩm)
-- Chỉ cho phép xóa sản phẩm Pending/Rejected và chưa phát sinh dữ liệu nghiệp vụ.
-- ============================================================
CREATE PROCEDURE sp_delete_product(
    IN p_product_id INT
)
BEGIN
    DECLARE v_status VARCHAR(50);
    DECLARE v_cnt INT DEFAULT 0;

    IF p_product_id IS NULL THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Lỗi Nghiệp Vụ: Product_ID không được để trống.';
    END IF;

    SELECT `status`
    INTO v_status
    FROM PRODUCT
    WHERE Product_ID = p_product_id;

    IF v_status IS NULL THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Lỗi Nghiệp Vụ: Sản phẩm không tồn tại.';
    END IF;

    IF v_status NOT IN ('Pending', 'Rejected') THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Lỗi Nghiệp Vụ: Chỉ được xóa sản phẩm đang Pending hoặc Rejected. Sản phẩm đã Approved nên chỉ nên ẩn/hủy duyệt để bảo toàn lịch sử.';
    END IF;

    SELECT COUNT(*)
    INTO v_cnt
    FROM STORE_PRODUCT
    WHERE Product_ID = p_product_id;

    IF v_cnt > 0 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Lỗi Nghiệp Vụ: Sản phẩm này đã được liên kết với cửa hàng trong STORE_PRODUCT, không được xóa.';
    END IF;

    SELECT COUNT(*)
    INTO v_cnt
    FROM CART_ITEM
    WHERE Product_ID = p_product_id;

    IF v_cnt > 0 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Lỗi Nghiệp Vụ: Sản phẩm đang tồn tại trong giỏ hàng, không được xóa.';
    END IF;

    SELECT COUNT(*)
    INTO v_cnt
    FROM ORDER_ITEM
    WHERE Product_ID = p_product_id;

    IF v_cnt > 0 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Lỗi Nghiệp Vụ: Sản phẩm đã phát sinh lịch sử đặt hàng, không được xóa.';
    END IF;

    DELETE FROM PRODUCT
    WHERE Product_ID = p_product_id;

    SELECT p_product_id AS Product_ID, 'Đã xóa sản phẩm thành công.' AS Message;
END$$

DELIMITER ;

-- ==========================================
-- TEST THỦ TỤC 3
-- ==========================================
/*
-- TH1: Xóa sản phẩm Pending chưa ai bán
CALL sp_insert_product(1, 'Áo nháp', '...', 'Brand', 'img.png', 'Pending', 6);
-- Lấy ID vừa thêm để xóa
CALL sp_delete_product(LAST_INSERT_ID());

-- TH2: Bắt lỗi khi cố xóa sản phẩm đã được bán / đã map store_product
CALL sp_delete_product(1);
*/
