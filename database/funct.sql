USE Omnilogi;

DROP FUNCTION IF EXISTS fn_recommend_products;
DELIMITER //
DROP FUNCTION IF EXISTS fn_recommend_products;
DELIMITER //

CREATE FUNCTION fn_recommend_products(p_product_id INT, p_min_confidence DECIMAL(5,2)) 
RETURNS TEXT
DETERMINISTIC
READS SQL DATA
BEGIN
    DECLARE v_related_product_id INT;
    DECLARE v_related_product_name VARCHAR(100);
    DECLARE v_occurrence_count INT;
    DECLARE v_total_orders INT DEFAULT 0;
    DECLARE v_confidence DECIMAL(5,2);
    DECLARE v_result TEXT DEFAULT '';
    DECLARE v_count INT DEFAULT 0;
    DECLARE done INT DEFAULT 0;
    DECLARE v_product_name VARCHAR(100);
    
    -- Khai báo con trỏ lấy danh sách sản phẩm mua cùng
    DECLARE cur_related CURSOR FOR 
        SELECT 
            oi2.Product_ID,
            COUNT(*) AS occurrence_count
        FROM ORDER_ITEM oi1
        JOIN ORDER_ITEM oi2 ON oi1.Order_ID = oi2.Order_ID 
        WHERE oi1.Product_ID = p_product_id 
          AND oi2.Product_ID != p_product_id
        GROUP BY oi2.Product_ID
        ORDER BY occurrence_count DESC;
        
    DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = 1;

    -- 1. Kiểm tra đầu vào
    IF p_product_id IS NULL THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'LỖI: Mã sản phẩm không được NULL';
    END IF;

    SELECT Name INTO v_product_name FROM PRODUCT WHERE Product_ID = p_product_id LIMIT 1;
    IF v_product_name IS NULL THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'LỖI: Sản phẩm không tồn tại';
    END IF;

    -- 2. Tính tổng số đơn hàng có chứa sản phẩm chính
    SELECT COUNT(DISTINCT Order_ID) INTO v_total_orders 
    FROM ORDER_ITEM 
    WHERE Product_ID = p_product_id;

    IF v_total_orders = 0 THEN
        RETURN CONCAT('Sản phẩm "', v_product_name, '" chưa có lịch sử giao dịch.');
    END IF;

    -- 3. Chạy vòng lặp con trỏ
    OPEN cur_related;
    product_loop: LOOP
        FETCH cur_related INTO v_related_product_id, v_occurrence_count;
        IF done THEN LEAVE product_loop; END IF;
        
        -- Tính độ tin cậy
        SET v_confidence = (v_occurrence_count * 100.0) / v_total_orders;
        
        -- Kiểm tra điều kiện lọc
        IF v_confidence >= p_min_confidence THEN
            -- Lấy tên sản phẩm gợi ý
            SELECT Name INTO v_related_product_name FROM PRODUCT WHERE Product_ID = v_related_product_id LIMIT 1;
            
            -- SỬA Ở ĐÂY: Nối chuỗi bằng ký tự xuống dòng '\n' và thêm gạch đầu dòng
            IF v_result = '' THEN
                SET v_result = CONCAT('- ', v_related_product_name, ' (', ROUND(v_confidence, 1), '%)');
            ELSE
                SET v_result = CONCAT(v_result, '\n', '- ', v_related_product_name, ' (', ROUND(v_confidence, 1), '%)');
            END IF;
            
            SET v_count = v_count + 1;
        END IF;
    END LOOP;
    CLOSE cur_related;

    -- 4. Trả về kết quả
    IF v_count = 0 THEN
        RETURN CONCAT('Không có sản phẩm gợi ý nào đạt độ tin cậy >= ', ROUND(p_min_confidence, 1), '%');
    END IF;

    RETURN v_result;
END //

DELIMITER ;

DELIMITER ;
-- ============================================================
-- HÀM XẾP HẠNG KHÁCH HÀNG DỰA TRÊN TỔNG CHI TIÊU
-- ============================================================

DROP FUNCTION IF EXISTS fn_get_customer_tier;
DELIMITER //

CREATE FUNCTION fn_get_customer_tier(p_customer_id INT)
RETURNS VARCHAR(50)
DETERMINISTIC
READS SQL DATA
BEGIN
    DECLARE done INT DEFAULT 0;
    DECLARE v_order_total DECIMAL(15,2);
    DECLARE v_sum_spent DECIMAL(15,2) DEFAULT 0;
    DECLARE v_tier VARCHAR(20);
    
    -- Khai báo con trỏ lấy giá trị thanh toán của các đơn hàng 'Completed'
    DECLARE cur_orders CURSOR FOR 
        SELECT Amount 
        FROM PAYMENT p
        JOIN `ORDER` o ON p.Order_ID = o.Order_ID
        WHERE o.Customer_ID = p_customer_id AND o.Order_status = 'Completed';
        
    DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = 1;

    -- 1. Kiểm tra tham số đầu vào
    IF p_customer_id IS NULL THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Lỗi: ID khách hàng không được để trống';
    END IF;

    -- Kiểm tra khách hàng có tồn tại không
    IF NOT EXISTS (SELECT 1 FROM CUSTOMER WHERE User_ID = p_customer_id) THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Lỗi: Khách hàng không tồn tại';
    END IF;

    -- 2. Sử dụng LOOP và CURSOR để tính tổng chi tiêu
    OPEN cur_orders;
    order_loop: LOOP
        FETCH cur_orders INTO v_order_total;
        IF done THEN LEAVE order_loop; END IF;
        
        SET v_sum_spent = v_sum_spent + v_order_total;
    END LOOP;
    CLOSE cur_orders;

    -- 3. Sử dụng IF để phân hạng dựa trên kết quả tính toán
    IF v_sum_spent >= 10000000 THEN 
        SET v_tier = 'DIAMOND';
    ELSEIF v_sum_spent >= 5000000 THEN 
        SET v_tier = 'GOLD';
    ELSEIF v_sum_spent >= 1000000 THEN 
        SET v_tier = 'SILVER';
    ELSE 
        SET v_tier = 'BRONZE';
    END IF;

    RETURN v_tier;
END //
DELIMITER ;
SELECT 'THÀNH CÔNG' AS Ket_qua;

DELIMITER $$

DELIMITER $$

DROP PROCEDURE IF EXISTS sp_test_function$$

CREATE PROCEDURE sp_test_function()
BEGIN
    -- ĐƯA TOÀN BỘ KHAI BÁO BIẾN LÊN ĐẦU
    DECLARE v_new_user_id INT;

    -- ============================================================
    -- PHẦN A: TEST fn_recommend_products
    -- ============================================================
    SELECT '--- TEST 1: Gợi ý sản phẩm cho Product_ID = 1 (Ngưỡng 40%) ---' AS Test_Name;

    -- 1. Hiện dữ liệu gốc để đối chiếu tỷ lệ
    SELECT 'BẢNG DỮ LIỆU GỐC: Các sản phẩm mua kèm Product 1' AS Step;
    SELECT 
        oi1.Order_ID, 
        oi1.Product_ID AS Main_Product, 
        oi2.Product_ID AS Bought_With_Product,
        p.Name AS Bought_With_Name
    FROM ORDER_ITEM oi1
    JOIN ORDER_ITEM oi2 ON oi1.Order_ID = oi2.Order_ID 
    JOIN PRODUCT p ON oi2.Product_ID = p.Product_ID
    WHERE oi1.Product_ID = 1 
      AND oi2.Product_ID != 1;

    -- 2. Hiện kết quả từ Function
    SELECT 'KẾT QUẢ TỪ FUNCTION:' AS Step;
    SELECT fn_recommend_products(1, 40) AS Recommendation_Result;


    SELECT '--- TEST 2: Bắt lỗi sản phẩm không tồn tại (Product_ID = 999) ---' AS Test_Name;
    -- Xử lý bắt lỗi do IF NULL / SIGNAL SQLSTATE trong function gây ra để không bị dừng Procedure
    BEGIN
        DECLARE CONTINUE HANDLER FOR SQLEXCEPTION
        BEGIN
            SELECT 'KẾT QUẢ: Lỗi đúng như kỳ vọng (Sản phẩm không tồn tại)' AS Result;
        END;
        SELECT fn_recommend_products(999, 10);
    END;

    -- ============================================================
    -- PHẦN B: TEST fn_get_customer_tier
    -- ============================================================
    SELECT '--- TEST 3: Xếp hạng khách hàng cho Customer_ID = 12 ---' AS Test_Name;

    -- 1. Hiện dữ liệu chi tiêu thô
    SELECT 'BẢNG DỮ LIỆU GỐC: Lịch sử thanh toán các đơn Completed của Customer 12' AS Step;
    SELECT 
        o.Order_ID, 
        o.Order_status, 
        p.Amount 
    FROM PAYMENT p
    JOIN `ORDER` o ON p.Order_ID = o.Order_ID
    WHERE o.Customer_ID = 12 
      AND o.Order_status = 'Completed';

    -- Hiện tổng tiền tính toán tay để so sánh chéo
    SELECT SUM(p.Amount) AS Total_Spent_Calculated
    FROM PAYMENT p
    JOIN `ORDER` o ON p.Order_ID = o.Order_ID
    WHERE o.Customer_ID = 12 AND o.Order_status = 'Completed';

    -- 2. Hiện kết quả từ Function
    SELECT 'KẾT QUẢ TỪ FUNCTION:' AS Step;
    SELECT 
        User_name, 
        fn_get_customer_tier(12) AS Membership_Status
    FROM USER 
    WHERE User_ID = 12;

    -- ============================================================
    -- TEST 4: KHÁCH HÀNG MỚI (BRONZE)
    -- ============================================================
    SELECT '--- TEST 4: TẠO MỚI KHÁCH HÀNG VÀ TEST HẠNG BRONZE (Không có đơn hàng) ---' AS Test_Name;
    
    -- 1. Insert User & Customer mới
    INSERT INTO USER (User_Role, User_name, `Password`, Email, First_name, Last_name, Gender, Date_of_birth, User_status, Created_date, Admin_ID)
    VALUES ('Customer', 'test_bronze_vy', '123456', 'testbronze@example.com', 'Test', 'Bronze', 'Female', '2000-01-01', 'Active', NOW(), NULL);
    
    SET @v_new_user_id = LAST_INSERT_ID();

	INSERT INTO CUSTOMER (User_ID)
	VALUES (@v_new_user_id);

	-- 2. Kết quả từ Function
	SELECT 'KẾT QUẢ TỪ FUNCTION (Kỳ vọng: BRONZE):' AS Step;
	SELECT 
		User_name, 
		fn_get_customer_tier(@v_new_user_id) AS Membership_Status
	FROM USER 
	WHERE User_ID = @v_new_user_id;

	-- 3. Cleanup (Dọn dẹp dữ liệu test)
	DELETE FROM CUSTOMER WHERE User_ID IN (SELECT User_ID FROM USER WHERE User_name = 'test_bronze_vy');
	DELETE FROM USER WHERE User_name = 'test_bronze_vy';
	DELETE FROM CUSTOMER WHERE User_ID IN (SELECT User_ID FROM USER WHERE Email = 'testbronze@example.com');
	DELETE FROM USER WHERE Email = 'testbronze@example.com';
    SELECT 'Đã dọn dẹp dữ liệu test.' AS Cleanup_Status;

END$$

DELIMITER ;

-- Chạy thử nghiệm
CALL sp_test_function();

-- Dọn dẹp
DROP PROCEDURE IF EXISTS sp_test_function;