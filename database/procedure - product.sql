-- ============================================================
--  OmniLogi - Hệ thống sàn TMĐT tích hợp Logistics
--  Phần 4: THỦ TỤC TRUY VẤN
-- ============================================================

USE Omnilogi;

DROP PROCEDURE IF EXISTS sp_get_all_products;
DROP PROCEDURE IF EXISTS sp_get_store_revenue_stats;

DELIMITER $$
-- ============================================================
-- THỦ TỤC 1: sp_get_all_products
-- ============================================================
CREATE PROCEDURE sp_get_all_products(
    IN p_status        VARCHAR(50),
    IN p_category_id   INT,
    IN p_search_string VARCHAR(100)
)
BEGIN
    DECLARE v_cnt INT DEFAULT 0;
    DECLARE v_search_keyword VARCHAR(100);

    IF p_status IS NOT NULL AND p_status NOT IN ('Pending', 'Approved', 'Rejected') THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Lỗi Nghiệp Vụ: Trạng thái lọc không hợp lệ.';
    END IF;

    IF p_category_id IS NOT NULL THEN
        SELECT COUNT(*)
        INTO v_cnt
        FROM CATEGORY
        WHERE Category_ID = p_category_id;

        IF v_cnt = 0 THEN
            SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Lỗi Nghiệp Vụ: Category_ID dùng để lọc không tồn tại.';
        END IF;
    END IF;

    SET v_search_keyword = NULLIF(TRIM(p_search_string), '');

    SELECT
        p.Product_ID,
        p.`Name` AS Ten_San_Pham,
        p.Brand AS Thuong_Hieu,
        c.Category_name AS Danh_Muc,
        p.`status` AS Trang_Thai,
        p.image_url,
        p.`Description` AS Mo_Ta,
        COALESCE(CONCAT_WS(' ', u.First_name, u.Middle_name, u.Last_name), 'Admin hệ thống') AS Nguoi_De_Xuat,
        COUNT(DISTINCT sp.Store_ID) AS So_Cua_Hang_Ban
    FROM PRODUCT p
    JOIN CATEGORY c
        ON p.Category_ID = c.Category_ID
    LEFT JOIN STORE_MANAGER sm
        ON p.Created_by_ID = sm.User_ID
    LEFT JOIN USER u
        ON sm.User_ID = u.User_ID
    LEFT JOIN STORE_PRODUCT sp
        ON p.Product_ID = sp.Product_ID
    WHERE
        (p_status IS NULL OR p.`status` = p_status)
        AND (p_category_id IS NULL OR p.Category_ID = p_category_id)
        AND (
            v_search_keyword IS NULL
            OR p.`Name` COLLATE utf8mb4_0900_as_ci LIKE CONCAT('%', v_search_keyword, '%')
            OR COALESCE(p.Brand, '') COLLATE utf8mb4_0900_as_ci LIKE CONCAT('%', v_search_keyword, '%')
            OR COALESCE(p.`Description`, '') COLLATE utf8mb4_0900_as_ci LIKE CONCAT('%', v_search_keyword, '%')
            OR c.Category_name COLLATE utf8mb4_0900_as_ci LIKE CONCAT('%', v_search_keyword, '%')
        )
    GROUP BY
        p.Product_ID,
        p.`Name`,
        p.Brand,
        c.Category_name,
        p.`status`,
        p.image_url,
        p.`Description`,
        u.First_name,
        u.Middle_name,
        u.Last_name
    ORDER BY
        p.Product_ID DESC;
END$$

DELIMITER ;

-- ==========================================
-- TEST THỦ TỤC 1
-- ==========================================
/*
-- TH1: Trang chủ: Lấy tất cả sản phẩm đã được duyệt (Approved)
CALL sp_get_all_products('Approved', NULL, NULL);

-- TH2: Lọc sản phẩm Điện tử (Category = 1) có chứa chữ "iPhone"
CALL sp_get_all_products('Approved', 1, 'iPhone');

-- TH3: Màn Admin: Xem tất cả sản phẩm (kể cả Pending) để duyệt
CALL sp_get_all_products(NULL, NULL, NULL);
*/

-- ============================================================
-- THỦ TỤC 2: sp_get_store_revenue_stats
-- Join nhiều bảng + aggregate function + group by + having + order by.
-- ============================================================
CREATE PROCEDURE sp_get_store_revenue_stats(
    IN p_store_id    INT,
    IN p_from_date   DATE,
    IN p_to_date     DATE,
    IN p_min_revenue DECIMAL(15,2)
)
BEGIN
    DECLARE v_cnt INT DEFAULT 0;

    IF p_store_id IS NOT NULL THEN
        SELECT COUNT(*)
        INTO v_cnt
        FROM STORE
        WHERE Store_ID = p_store_id;

        IF v_cnt = 0 THEN
            SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Lỗi Nghiệp Vụ: Store_ID dùng để thống kê không tồn tại.';
        END IF;
    END IF;

    IF p_from_date IS NOT NULL AND p_to_date IS NOT NULL AND p_from_date > p_to_date THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Lỗi Nghiệp Vụ: Ngày bắt đầu không được lớn hơn ngày kết thúc.';
    END IF;

    SELECT
        s.Store_ID AS Ma_Cua_Hang,
        s.`Name` AS Ten_Cua_Hang,
        CONCAT_WS(' ', u.First_name, u.Middle_name, u.Last_name) AS Quan_Ly,
        COUNT(DISTINCT o.Order_ID) AS Tong_Don_Hoan_Thanh,
        SUM(oi.Quantity) AS Tong_SL_Da_Ban,
        SUM(oi.Quantity * oi.Price_of_purchase) AS Tong_Doanh_Thu_VND,
        COALESCE(ROUND(AVG(r.Rating), 1), 0) AS Diem_DG_TB
    FROM STORE s
    JOIN STORE_MANAGER sm
        ON sm.User_ID = s.Manager_ID
    JOIN USER u
        ON u.User_ID = sm.User_ID
    JOIN STORE_PRODUCT sp
        ON sp.Store_ID = s.Store_ID
    JOIN ORDER_ITEM oi
        ON oi.SProduct_ID = sp.SProduct_ID
       AND oi.Store_ID = s.Store_ID
    JOIN `ORDER` o
        ON o.Order_ID = oi.Order_ID
       AND o.Order_status = 'Completed'
    LEFT JOIN REVIEW r
        ON r.Order_ID = oi.Order_ID
       AND r.Item_ID = oi.Item_ID
    WHERE
        (p_store_id IS NULL OR s.Store_ID = p_store_id)
        AND (p_from_date IS NULL OR o.Order_date >= p_from_date)
        AND (p_to_date IS NULL OR o.Order_date <= p_to_date)
    GROUP BY
        s.Store_ID,
        s.`Name`,
        u.First_name,
        u.Middle_name,
        u.Last_name
    HAVING
        (p_min_revenue IS NULL OR SUM(oi.Quantity * oi.Price_of_purchase) >= p_min_revenue)
    ORDER BY
        SUM(oi.Quantity * oi.Price_of_purchase) DESC,
        s.Store_ID ASC;
END$$

DELIMITER ;

-- ==========================================
-- TEST THỦ TỤC 2
-- ==========================================
/*
-- TH1: Thống kê doanh thu tất cả cửa hàng
CALL sp_get_store_revenue_stats(NULL, NULL, NULL, NULL);

-- TH2: Lọc doanh thu theo tháng 3/2025 và doanh thu > 20 triệu VND
CALL sp_get_store_revenue_stats(NULL, '2025-03-01', '2025-03-31', 20000000);
*/