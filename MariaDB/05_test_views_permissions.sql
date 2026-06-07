-- =============================================
-- 05_test_views_permissions.sql
-- View 與使用者權限測試
-- =============================================

USE nfu;

-- =============================================
-- 一、View 測試
-- =============================================

SELECT '=== v_available_equipment 可借用設備 ===' AS '';
SELECT * FROM v_available_equipment;

SELECT '=== v_borrowed_equipment 借出中設備 ===' AS '';
SELECT * FROM v_borrowed_equipment;

SELECT '=== v_pending_maintenance 待處理維護 ===' AS '';
SELECT * FROM v_pending_maintenance;

SELECT '=== v_pending_retire 待審核報廢 ===' AS '';
SELECT * FROM v_pending_retire;

SELECT '=== v_equipment_full 設備完整資訊 ===' AS '';
SELECT * FROM v_equipment_full;


-- =============================================
-- 二、admin_user 權限測試（應全部成功）
-- =============================================

SELECT '=== 切換到 admin_user ===' AS '';

-- 測試 admin_user SELECT
SELECT '測試 admin_user SELECT Member（應成功）' AS 測試項目;
SELECT mId, mName, mRole FROM Member
    LIMIT 3; -- 用 root 模擬，實際需以 admin_user 登入

-- =============================================
-- 三、staff_user 權限測試
-- 以下用 root 模擬，實際請以 staff_user 登入測試
-- =============================================

-- 測試 staff_user 可以 INSERT BorrowRecord（應成功）
SELECT '測試 staff_user INSERT BorrowRecord（應成功）' AS 測試項目;
INSERT INTO BorrowRecord (mId, eId, bApplyDate, bStartDate, bEndDate, bStatus)
VALUES (3, 4, '2026-06-01', '2026-06-02', '2026-06-10', '申請中');
SELECT '成功新增借用申請' AS 結果;

-- 測試 staff_user 可以 INSERT MaintenanceRecord（應成功）
SELECT '測試 staff_user INSERT MaintenanceRecord（應成功）' AS 測試項目;
INSERT INTO MaintenanceRecord (eId, mId, mRecDate, mIssue, mStatus)
VALUES (4, 3, '2026-06-01', '測試維護申報', '待處理');
SELECT '成功新增維護申報' AS 結果;

-- 測試 staff_user 可以 INSERT RetirementRequest（應成功）
SELECT '測試 staff_user INSERT RetirementRequest（應成功）' AS 測試項目;
INSERT INTO RetirementRequest (eId, mId, retDate, retReason, retStatus)
VALUES (5, 3, '2026-06-01', '測試報廢申請', '待審核');
SELECT '成功新增報廢申請' AS 結果;

-- 清除測試資料
DELETE FROM BorrowRecord WHERE bApplyDate = '2026-06-01' AND mId = 3;
DELETE FROM MaintenanceRecord WHERE mRecDate = '2026-06-01' AND mIssue = '測試維護申報';
DELETE FROM RetirementRequest WHERE retDate = '2026-06-01' AND retReason = '測試報廢申請';
SELECT '測試資料清除完成' AS 結果;


-- =============================================
-- 四、實際切換 staff_user 測試 UPDATE（應報錯）
-- 請在 cmd 執行以下指令：
-- mysql -u staff_user -p nfu
-- 密碼：Staff@1234
-- 然後執行：
-- UPDATE Equipment SET eStatus = '報廢' WHERE eId = 1;
-- 應該出現 ERROR 1142: UPDATE command denied
-- =============================================
SELECT '請以 staff_user 登入測試 UPDATE 是否被拒絕（見上方說明）' AS 提醒;


-- =============================================
-- 五、確認權限設定
-- =============================================
SELECT '=== admin_user 權限 ===' AS '';
SHOW GRANTS FOR 'admin_user'@'localhost';

SELECT '=== staff_user 權限 ===' AS '';
SHOW GRANTS FOR 'staff_user'@'localhost';
