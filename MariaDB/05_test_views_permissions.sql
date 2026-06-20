-- =============================================
-- 資工系設備管理與維護系統
-- 05_test_views_permissions.sql

USE nfu;

-- =============================================
-- 一、管理員視角 View 測試
-- =============================================

SELECT '=== v_admin_dashboard_pending 待處理事項總覽 ===' AS '';
-- 應顯示：BorrowRecord#9(申請中)、MaintenanceRecord#5(處理中)/#9(待處理)、
--         RetirementRequest#6(待審核)
SELECT * FROM v_admin_dashboard_pending;

SELECT '=== v_admin_equipment_overview 設備總覽（現役9台） ===' AS '';
SELECT * FROM v_admin_equipment_overview;

SELECT '=== v_admin_retired_equipment 已報廢設備列表（應有1筆：iPad Air） ===' AS '';
SELECT * FROM v_admin_retired_equipment;


-- =============================================
-- 二、學生/教師視角 View 測試
-- =============================================

SELECT '=== v_user_available_equipment 目前可借用設備（應為eId=3,4,6） ===' AS '';
SELECT * FROM v_user_available_equipment;

SELECT '=== v_user_my_borrows 我的借用紀錄（以 mId=3 為例，應有2筆） ===' AS '';
SELECT * FROM v_user_my_borrows WHERE 我的mId = 3;

SELECT '=== v_user_my_maintenance 我的維護申報（以 mId=4 為例，應有2筆，含已報廢設備） ===' AS '';
SELECT * FROM v_user_my_maintenance WHERE 我的mId = 4;

SELECT '=== v_user_my_retirements 我的報廢申請（以 mId=2 為例，應有2筆，含已核准搬移） ===' AS '';
SELECT * FROM v_user_my_retirements WHERE 我的mId = 2;


-- =============================================
-- 三、admin_user 權限測試
-- 以下用 root 模擬，實際請以 admin_user 登入測試
-- =============================================

SELECT '=== 測試 admin_user SELECT Member（應成功） ===' AS '';
SELECT mId, mName, mRole FROM Member LIMIT 3;

SELECT '=== 測試 admin_user UPDATE BorrowRecord（應成功，審核功能） ===' AS '';
-- 模擬管理員審核 Borrow#9（待審核 → 核准）
UPDATE BorrowRecord SET bStatus='核准', bApprovedBy=1, bApprovedDate=CURRENT_DATE WHERE bId=9;
SELECT bId, bStatus, bApprovedBy FROM BorrowRecord WHERE bId=9;
-- 還原
UPDATE BorrowRecord SET bStatus='申請中', bApprovedBy=NULL, bApprovedDate=NULL WHERE bId=9;


-- =============================================
-- 四、staff_user 權限測試
-- 以下用 root 模擬，實際請以 staff_user 登入測試
-- =============================================

-- 測試 staff_user 可以 INSERT BorrowRecord（應成功，前提：設備為可用）
SELECT '=== 測試 staff_user INSERT BorrowRecord（應成功） ===' AS '';
INSERT INTO BorrowRecord (bId, mId, eId, bApplyDate, bStartDate, bEndDate, bStatus)
VALUES (200, 3, 6, '2026-06-10', '2026-06-11', '2026-06-15', '申請中');
SELECT '成功新增借用申請，Equipment#6 應變為借出中' AS 結果;
SELECT eId, eStatus FROM Equipment WHERE eId = 6;

-- 測試 staff_user 可以 INSERT MaintenanceRecord（應成功，前提：設備為可用）
SELECT '=== 測試 staff_user INSERT MaintenanceRecord（應成功） ===' AS '';
INSERT INTO MaintenanceRecord (mRecId, eId, mId, mRecDate, mIssue, mStatus)
VALUES (200, 4, 3, '2026-06-10', '測試維護申報', '待處理');

-- 測試 staff_user 可以 INSERT RetirementRequest（應成功，前提：設備為可用）
-- 注意：eId=4 此時已被上面的 MaintenanceRecord 鎖定為「維修中」，
--       改用另一台目前「可用」的設備示範（依 02 結果，eId=3 或 6 為可用，
--       但 eId=6 已被借用鎖定，故此處用 eId=3）
SELECT '=== 測試 staff_user INSERT RetirementRequest（應成功） ===' AS '';
INSERT INTO RetirementRequest (retId, eId, mId, retDate, retReason, retStatus)
VALUES (200, 3, 3, '2026-06-10', '測試報廢申請', '待審核');

-- 清除測試資料（注意順序：先恢復設備狀態再刪除）
UPDATE BorrowRecord SET bStatus='拒絕', bApprovedBy=1, bApprovedDate=CURRENT_DATE,
       bRejectReason='測試結束清除' WHERE bId=200;
DELETE FROM BorrowRecord WHERE bId=200;

UPDATE MaintenanceRecord SET mStatus='拒絕', mStaff='測試',
       mRejectReason='測試結束清除' WHERE mRecId=200;
DELETE FROM MaintenanceRecord WHERE mRecId=200;

UPDATE RetirementRequest SET retStatus='駁回', retApprovedBy=1,
       retRejectReason='測試結束清除' WHERE retId=200;

SELECT '測試資料清除完成' AS 結果;


-- =============================================
-- 五、實際切換 staff_user 測試 UPDATE/DELETE（應報錯）
-- 請另開 cmd 視窗執行：
--   mysql -u staff_user -p nfu   （密碼：Staff@1234）
-- 然後執行：
--   UPDATE Equipment SET eStatus = '可用' WHERE eId = 1;
--   → 應出現 ERROR 1142: UPDATE command denied
--
--   DELETE FROM Equipment WHERE eId = 1;
--   → 應出現 ERROR 1142: DELETE command denied
-- =============================================
SELECT '請以 staff_user 登入測試 UPDATE/DELETE 是否被拒絕（見上方說明）' AS 提醒;


-- =============================================
-- 六、確認權限設定
-- =============================================
SELECT '=== admin_user 權限 ===' AS '';
SHOW GRANTS FOR 'admin_user'@'localhost';

SELECT '=== staff_user 權限 ===' AS '';
SHOW GRANTS FOR 'staff_user'@'localhost';
