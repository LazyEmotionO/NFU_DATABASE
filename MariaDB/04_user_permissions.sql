-- =============================================
-- 資工系設備管理與維護系統
-- 04_user_permissions.sql
-- =============================================

USE nfu;

-- =============================================
-- 建立使用者帳號
-- =============================================

DROP USER IF EXISTS 'admin_user'@'localhost';
DROP USER IF EXISTS 'staff_user'@'localhost';

CREATE USER 'admin_user'@'localhost' IDENTIFIED BY 'Admin@1234';
CREATE USER 'staff_user'@'localhost' IDENTIFIED BY 'Staff@1234';


-- =============================================
-- 管理員權限：所有表完整操作
-- =============================================
GRANT SELECT, INSERT, UPDATE, DELETE ON nfu.Member             TO 'admin_user'@'localhost';
GRANT SELECT, INSERT, UPDATE, DELETE ON nfu.Equipment          TO 'admin_user'@'localhost';
GRANT SELECT, INSERT, UPDATE, DELETE ON nfu.Category           TO 'admin_user'@'localhost';
GRANT SELECT, INSERT, UPDATE, DELETE ON nfu.BorrowRecord       TO 'admin_user'@'localhost';
GRANT SELECT, INSERT, UPDATE, DELETE ON nfu.MaintenanceRecord  TO 'admin_user'@'localhost';
GRANT SELECT, INSERT, UPDATE, DELETE ON nfu.RetirementRequest  TO 'admin_user'@'localhost';
GRANT SELECT, INSERT, UPDATE, DELETE ON nfu.RetiredEquipment   TO 'admin_user'@'localhost';

-- 管理員可存取所有 View
GRANT SELECT ON nfu.v_admin_dashboard_pending    TO 'admin_user'@'localhost';
GRANT SELECT ON nfu.v_admin_equipment_overview   TO 'admin_user'@'localhost';
GRANT SELECT ON nfu.v_admin_retired_equipment    TO 'admin_user'@'localhost';
GRANT SELECT ON nfu.v_user_available_equipment   TO 'admin_user'@'localhost';
GRANT SELECT ON nfu.v_user_my_borrows            TO 'admin_user'@'localhost';
GRANT SELECT ON nfu.v_user_my_maintenance        TO 'admin_user'@'localhost';
GRANT SELECT ON nfu.v_user_my_retirements        TO 'admin_user'@'localhost';


-- =============================================
-- 教師/學生權限：查詢所有表、新增借用/維護/報廢申請
-- =============================================

-- 查詢權限（所有表，含已報廢設備供查詢歷史）
GRANT SELECT ON nfu.Member             TO 'staff_user'@'localhost';
GRANT SELECT ON nfu.Equipment          TO 'staff_user'@'localhost';
GRANT SELECT ON nfu.Category           TO 'staff_user'@'localhost';
GRANT SELECT ON nfu.BorrowRecord       TO 'staff_user'@'localhost';
GRANT SELECT ON nfu.MaintenanceRecord  TO 'staff_user'@'localhost';
GRANT SELECT ON nfu.RetirementRequest  TO 'staff_user'@'localhost';
GRANT SELECT ON nfu.RetiredEquipment   TO 'staff_user'@'localhost';

-- 新增借用/維護/報廢申請
GRANT INSERT ON nfu.BorrowRecord       TO 'staff_user'@'localhost';
GRANT INSERT ON nfu.MaintenanceRecord  TO 'staff_user'@'localhost';
GRANT INSERT ON nfu.RetirementRequest  TO 'staff_user'@'localhost';

-- 教師/學生可存取的 View（使用者視角）
GRANT SELECT ON nfu.v_user_available_equipment TO 'staff_user'@'localhost';
GRANT SELECT ON nfu.v_user_my_borrows          TO 'staff_user'@'localhost';
GRANT SELECT ON nfu.v_user_my_maintenance      TO 'staff_user'@'localhost';
GRANT SELECT ON nfu.v_user_my_retirements      TO 'staff_user'@'localhost';


-- =============================================
-- 套用權限
-- =============================================
FLUSH PRIVILEGES;


-- =============================================
-- 確認權限設定
-- =============================================
SELECT '=== admin_user 權限 ===' AS '';
SHOW GRANTS FOR 'admin_user'@'localhost';

SELECT '=== staff_user 權限 ===' AS '';
SHOW GRANTS FOR 'staff_user'@'localhost';
