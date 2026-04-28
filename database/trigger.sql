=====================================================
-- TRIGGERS 
-- =====================================================

DELIMITER $$

-- =====================================================
-- 1. TRIGGER CẬP NHẬT TOTAL_DELIVERIES 
-- =====================================================
-- INSERT
DROP TRIGGER IF EXISTS trg_UpdateDelivery_Insert$$
CREATE TRIGGER trg_UpdateDelivery_Insert
AFTER INSERT ON SHIPMENT
FOR EACH ROW
BEGIN
    IF NEW.Driver_ID IS NOT NULL AND NEW.`Status` = 'Delivered' THEN
        UPDATE DRIVER 
        SET Total_deliveries = (
            SELECT COUNT(*) 
            FROM SHIPMENT s
            WHERE s.Driver_ID = DRIVER.User_ID 
              AND s.`Status` = 'Delivered'
        )
        WHERE User_ID = NEW.Driver_ID;
    END IF;
END$$

-- UPDATE
DROP TRIGGER IF EXISTS trg_UpdateDelivery_Update$$
CREATE TRIGGER trg_UpdateDelivery_Update
AFTER UPDATE ON SHIPMENT
FOR EACH ROW
BEGIN
    -- Nếu đổi từ trạng thái khác sang Delivered -> Tăng 1
    IF (OLD.Status <> 'Delivered' OR OLD.Status IS NULL) AND NEW.Status = 'Delivered' THEN
        UPDATE DRIVER SET Total_deliveries = Total_deliveries + 1 
        WHERE User_ID = NEW.Driver_ID;
        
    -- Nếu đang Delivered mà bị đổi ngược lại (do lỗi nhập liệu) -> Giảm 1
    ELSEIF OLD.Status = 'Delivered' AND NEW.Status <> 'Delivered' THEN
        UPDATE DRIVER SET Total_deliveries = Total_deliveries - 1 
        WHERE User_ID = NEW.Driver_ID;
    END IF;
END$$

-- DELETE
DROP TRIGGER IF EXISTS trg_UpdateDelivery_Delete$$
CREATE TRIGGER trg_UpdateDelivery_Delete
AFTER DELETE ON SHIPMENT
FOR EACH ROW
BEGIN
    IF OLD.Status = 'Delivered' THEN
        UPDATE DRIVER SET Total_deliveries = Total_deliveries - 1 
        WHERE User_ID = OLD.Driver_ID;
    END IF;
END$$

-- =====================================================
-- 2. TRIGGER KIỂM TRA REVIEW
-- =====================================================
DROP TRIGGER IF EXISTS trg_Check_Review$$
CREATE TRIGGER trg_Check_Review
BEFORE INSERT ON REVIEW
FOR EACH ROW
BEGIN
    IF NOT EXISTS (
        SELECT 1   	
        FROM `ORDER` o
        JOIN ORDER_ITEM oi ON o.Order_ID = oi.Order_ID
        WHERE oi.Item_ID = NEW.Item_ID 
          AND oi.Order_ID = NEW.Order_ID
          AND o.Customer_ID = NEW.Customer_ID 
          AND o.Order_status = 'Completed'
    ) THEN
        SIGNAL SQLSTATE '45000' 
        SET MESSAGE_TEXT = 'Loi: Ban chi co the danh gia san pham khi don hang da hoan tat!';
    END IF;
END$$

DELIMITER ;
-- ============================================================
--  OmniLogi – Hệ thống sàn TMĐT tích hợp Logistics
--  Mô tả: Kiểm tra hoạt động trigger (Shipment & Review)
-- ============================================================

USE Omnilogi;

SET SQL_SAFE_UPDATES = 0;

DROP PROCEDURE IF EXISTS sp_test_trigger;

DELIMITER $$

CREATE PROCEDURE sp_test_trigger()
BEGIN

	DECLARE v_new_shipment_id INT;
    DECLARE v_new_review_id INT;
    DECLARE v_test_shipment_id INT;
    
    SELECT IFNULL(MAX(Shipment_ID), 0) + 1 INTO v_new_shipment_id FROM SHIPMENT;
    SELECT IFNULL(MAX(Review_ID), 0) + 1 INTO v_new_review_id FROM REVIEW;
    
    SELECT v_new_shipment_id AS New_Shipment_ID, v_new_review_id AS New_Review_ID;

	-- ==================================================
	-- PHẦN A: TEST TRIGGER SHIPMENT (Total_deliveries)
	-- ==================================================
    
	SELECT 'PHẦN A: TEST TRIGGER SHIPMENT';

	-- Test 1: INSERT Delivered
    
    SELECT 'BẢNG SHIPMENT TRƯỚC KHI INSERT (Driver 16):';
	SELECT Shipment_ID, Driver_ID, Order_ID, Status
	FROM SHIPMENT 
	WHERE Driver_ID = 16
	ORDER BY Shipment_ID;
    
	SELECT '--- TEST 1: INSERT Delivered ---' AS Test;
    
	-- BEFORE
	SET @before_val = (
		SELECT Total_deliveries
		FROM DRIVER
		WHERE User_ID = 16
	);

	-- INSERT
	INSERT INTO SHIPMENT (Shipment_ID, Driver_ID, Order_ID, Status)
	VALUES (v_new_shipment_id, 16, 11, 'Delivered');

	-- So sánh
	SELECT 
		@before_val AS BEFORE_Total_deliveries,
		(SELECT Total_deliveries FROM DRIVER WHERE User_ID = 16) AS AFTER_Total_deliveries;
        
        SET v_new_shipment_id = v_new_shipment_id + 1;
	
    SELECT 'BẢNG SHIPMENT SAU KHI INSERT (Driver 16):';
	SELECT Shipment_ID, Driver_ID, Order_ID, Status
	FROM SHIPMENT 
	WHERE Driver_ID = 16
	ORDER BY Shipment_ID;
    
	DELETE FROM SHIPMENT WHERE Shipment_ID = @new_shipment_id;
    
	-- TEST 2: UPDATE Shipping -> Delivered
	SELECT '--- TEST 2: UPDATE Shipping → Delivered (REAL DATA) ---' AS Test;

	SET @new_shipment_id = (SELECT IFNULL(MAX(Shipment_ID), 0) + 1 FROM SHIPMENT);

	INSERT INTO SHIPMENT (Shipment_ID, Driver_ID, Order_ID, Status)
	VALUES (@new_shipment_id, 18, 13, 'Shipping');
    
	SELECT 'BẢNG SHIPMENT TRƯỚC UPDATE (Driver 18):';
	SELECT Shipment_ID, Driver_ID, Order_ID, Status
	FROM SHIPMENT 
	WHERE Driver_ID = 18
	ORDER BY Shipment_ID;
		
	-- BEFORE
	SET @before_val = (
		SELECT Total_deliveries
		FROM DRIVER
		WHERE User_ID = 18
	);

	-- UPDATE từ Shipping → Delivered
	UPDATE SHIPMENT
	SET Status = 'Delivered'
	WHERE Shipment_ID = @new_shipment_id;

	SELECT 'BẢNG SHIPMENT SAU UPDATE (Driver 18):';
	SELECT Shipment_ID, Driver_ID, Order_ID, Status
	FROM SHIPMENT 
	WHERE Driver_ID = 18
	ORDER BY Shipment_ID;

	-- So sánh
	SELECT 
		@new_shipment_id AS Shipment_ID_Used,
		@before_val AS BEFORE_Total_deliveries,
		(SELECT Total_deliveries FROM DRIVER WHERE User_ID = 18) AS AFTER_Total_deliveries;
		
	DELETE FROM SHIPMENT WHERE Shipment_ID = @new_shipment_id;
    
	-- =========================
	-- TEST 3: Delivered → Pending (GIẢM 1)
	-- =========================
	SELECT '--- TEST 3: UPDATE Delivered -> Pending ---' AS Test;

	SET @new_shipment_id = (SELECT IFNULL(MAX(Shipment_ID), 0) + 1 FROM SHIPMENT);

	INSERT INTO SHIPMENT (Shipment_ID, Driver_ID, Order_ID, Status)
	VALUES (@new_shipment_id, 17, 2, 'Delivered');
    
	SELECT 'BẢNG SHIPMENT TRƯỚC UPDATE (Driver 17):';
	SELECT Shipment_ID, Driver_ID, Order_ID, Status
	FROM SHIPMENT 
	WHERE Driver_ID = 17
	ORDER BY Shipment_ID;
    
	-- BEFORE
	SET @before_val = (
		SELECT Total_deliveries
		FROM DRIVER
		WHERE User_ID = 17
	);

	-- UPDATE shipment 
	UPDATE SHIPMENT
	SET Status = 'Pending'
	WHERE Shipment_ID = @new_shipment_id;

	SELECT 'BẢNG SHIPMENT SAU UPDATE (Driver 17):';
	SELECT Shipment_ID, Driver_ID, Order_ID, Status
	FROM SHIPMENT 
	WHERE Driver_ID = 17
	ORDER BY Shipment_ID;

	-- So sánh
    SELECT 
    @new_shipment_id AS Shipment_ID_Used,
    @before_val AS BEFORE_Total_Deliveries,
    (SELECT Total_deliveries FROM DRIVER WHERE User_ID = 17) AS AFTER_Total_Deliveries;
    
	DELETE FROM SHIPMENT WHERE Shipment_ID = @new_shipment_id;

	-- TEST 4: DELETE Shipment
	SELECT '--- TEST 4: DELETE Shipment ---' AS Test;
    
	SET @new_shipment_id = (SELECT IFNULL(MAX(Shipment_ID), 0) + 1 FROM SHIPMENT);

	INSERT INTO SHIPMENT (Shipment_ID, Driver_ID, Order_ID, Status)
	VALUES (@new_shipment_id, 20, 5, 'Delivered');
    
	SELECT 'BẢNG SHIPMENT TRƯỚC DELETE (Driver 20):';
	SELECT Shipment_ID, Driver_ID, Order_ID, Status
	FROM SHIPMENT 
	WHERE Driver_ID = 20
	ORDER BY Shipment_ID;

	-- BEFORE 
	SET @before_val = (
		SELECT Total_deliveries
		FROM DRIVER
		WHERE User_ID = 20
	);

	-- DELETE shipment đã Delivered
	DELETE FROM SHIPMENT
	WHERE Shipment_ID = @new_shipment_id;
    
	SELECT 'BẢNG SHIPMENT SAU DELETE (Driver 20):';
	SELECT Shipment_ID, Driver_ID, Order_ID, Status
	FROM SHIPMENT 
	WHERE Driver_ID = 20
	ORDER BY Shipment_ID;

	-- So sánh
	SELECT 
    @new_shipment_id AS Shipment_ID_Deleted,
    @before_val AS BEFORE_Total_Diliveries,
    (SELECT Total_deliveries FROM DRIVER WHERE User_ID = 20) AS AFTER_Total_Deliveries;
		
	-- ==================================================
	-- PHẦN B: TEST TRIGGER REVIEW
	-- ==================================================
	SELECT 'PHẦN B: TEST TRIGGER REVIEW';

	-- ==================================================
	-- TEST 5: REVIEW HỢP LỆ (PASS) - Tìm cặp chưa có review
	-- ==================================================
	SELECT '--- TEST 5: REVIEW HỢP LỆ (PASS) ---' AS Test;

	-- Tạo ID tự động cho review
	SET @new_review_id = (SELECT IFNULL(MAX(Review_ID), 0) + 1 FROM REVIEW);

	-- Tìm và insert review vào cặp (Order_ID, Item_ID) chưa có review
	INSERT INTO REVIEW (Review_ID, Item_ID, Order_ID, Customer_ID, Rating, Comment, Review_date)
	SELECT 
		@new_review_id,
		oi.Item_ID,
		oi.Order_ID,
		o.Customer_ID,
		5,
		'Test review hop le',
		CURDATE()
	FROM `ORDER` o
	JOIN ORDER_ITEM oi ON o.Order_ID = oi.Order_ID
	LEFT JOIN REVIEW r ON oi.Order_ID = r.Order_ID AND oi.Item_ID = r.Item_ID
	WHERE r.Order_ID IS NULL 
	  AND o.Order_status = 'Completed'
	LIMIT 1;

	-- Kiểm tra kết quả
	SELECT 
		@new_review_id AS New_Review_ID,
		'Insert review thành công!' AS Result;

	SELECT * FROM REVIEW WHERE Review_ID = @new_review_id;
    
	-- TEST 6: REVIEW KHÔNG HỢP LỆ
	SELECT '--- TEST 6: REVIEW KHÔNG HỢP LỆ (FAIL) ---' AS Test;

	BEGIN
		DECLARE CONTINUE HANDLER FOR SQLEXCEPTION
		BEGIN
			SELECT 'KẾT QUẢ: LỖI đúng như kỳ vọng – Không thể review sai dữ liệu' AS Result;
		END;

		-- Insert sai (Item không thuộc order)
		INSERT INTO REVIEW (Review_ID, Item_ID, Order_ID, Customer_ID, Rating)
		VALUES (101, 9999, 2, 16, 5);
	END;

END$$

DELIMITER ;

-- GỌI CHẠY TEST
CALL sp_test_trigger();

-- DỌN DẸP 
DROP PROCEDURE IF EXISTS sp_test_trigger;

