-- =============================================
-- 資工系設備管理與維護系統
-- command.sql
-- =============================================

USE nfu;

-- =============================================
-- 一、基本查詢
-- =============================================

SELECT * FROM Member;
SELECT * FROM Equipment;
SELECT * FROM Category;
SELECT * FROM BorrowRecord;
SELECT * FROM MaintenanceRecord;
SELECT * FROM RetirementRequest;
SELECT * FROM RetiredEquipment;


-- =============================================
-- 二、管理員視角 View 查詢
-- =============================================

-- 待處理事項總覽（借用申請+維護工單+報廢申請）
SELECT * FROM v_admin_dashboard_pending;

-- 設備總覽
SELECT * FROM v_admin_equipment_overview;

-- 已報廢設備列表
SELECT * FROM v_admin_retired_equipment;


-- =============================================
-- 三、學生/教師視角 View 查詢
-- =============================================

-- 目前可借用設備
SELECT * FROM v_user_available_equipment;

-- 我的借用紀錄（以 mId=3 為例）
SELECT * FROM v_user_my_borrows WHERE 我的mId = 3;

-- 我的維護申報紀錄（以 mId=2 為例）
SELECT * FROM v_user_my_maintenance WHERE 我的mId = 2;

-- 我的報廢申請紀錄（以 mId=2 為例）
SELECT * FROM v_user_my_retirements WHERE 我的mId = 2;


-- =============================================
-- 四、設備相關查詢
-- =============================================

-- 各類別的設備數量（現役設備）
SELECT c.cName, COUNT(e.eId) AS 設備數量
FROM Category c
LEFT JOIN Equipment e ON c.cId = e.cId
GROUP BY c.cId, c.cName;

-- 各狀態的設備數量
SELECT eStatus AS 狀態, COUNT(*) AS 數量
FROM Equipment
GROUP BY eStatus;

-- 保固即將到期的設備（90天內）
SELECT eId, ePropertyNo, eName, eWarrantyDate
FROM Equipment
WHERE eWarrantyDate IS NOT NULL
  AND eWarrantyDate <= DATE_ADD(CURRENT_DATE, INTERVAL 90 DAY)
  AND eWarrantyDate >= CURRENT_DATE;


-- =============================================
-- 五、借用相關查詢
-- =============================================

-- 目前逾期的借用紀錄
SELECT b.bId, mb.mName AS 借用人, e.eName AS 設備名稱,
       b.bStartDate AS 借用開始, b.bEndDate AS 應還日期
FROM BorrowRecord b
JOIN Member mb ON b.mId = mb.mId
LEFT JOIN Equipment e ON b.eId = e.eId
WHERE b.bStatus = '逾期';

-- 待審核的借用申請
SELECT b.bId, mb.mName AS 申請人, e.eName AS 設備名稱,
       b.bApplyDate AS 申請日期
FROM BorrowRecord b
JOIN Member mb ON b.mId = mb.mId
LEFT JOIN Equipment e ON b.eId = e.eId
WHERE b.bStatus = '申請中';


-- =============================================
-- 六、維護相關查詢
-- =============================================

-- 待處理/處理中的維護紀錄
SELECT m.mRecId, e.eName AS 設備名稱, mb.mName AS 申報人,
       m.mRecDate AS 申報日期, m.mIssue AS 問題描述, m.mStatus AS 狀態
FROM MaintenanceRecord m
JOIN Member mb ON m.mId = mb.mId
LEFT JOIN Equipment e ON m.eId = e.eId
WHERE m.mStatus IN ('待處理', '處理中');

-- 各設備的維護次數（含已報廢設備的歷史紀錄，eId 為 NULL 表示設備已報廢）
SELECT COALESCE(e.eName, '(已報廢設備)') AS 設備名稱, COUNT(m.mRecId) AS 維護次數
FROM MaintenanceRecord m
LEFT JOIN Equipment e ON m.eId = e.eId
GROUP BY e.eId, e.eName
ORDER BY 維護次數 DESC;


-- =============================================
-- 七、報廢相關查詢
-- =============================================

-- 待審核的報廢申請
SELECT r.retId, e.eName AS 設備名稱, mb.mName AS 申請人,
       r.retDate AS 申請日期, r.retReason AS 報廢原因
FROM RetirementRequest r
JOIN Member mb ON r.mId = mb.mId
LEFT JOIN Equipment e ON r.eId = e.eId
WHERE r.retStatus = '待審核';

-- 已報廢設備的完整歸檔資訊
SELECT re.ePropertyNo, re.eName, c.cName AS 類別,
       re.retReason, mb.mName AS 審核人, re.retiredDate
FROM RetiredEquipment re
JOIN Category c ON re.cId = c.cId
JOIN Member mb ON re.retApprovedBy = mb.mId;


-- =============================================
-- 八、統計報表查詢
-- =============================================

-- 設備狀態總覽（含已報廢數量）
SELECT
    SUM(CASE WHEN eStatus = '可用'   THEN 1 ELSE 0 END) AS 可用,
    SUM(CASE WHEN eStatus = '借出中' THEN 1 ELSE 0 END) AS 借出中,
    SUM(CASE WHEN eStatus = '維修中' THEN 1 ELSE 0 END) AS 維修中,
    SUM(CASE WHEN eStatus = '報廢中' THEN 1 ELSE 0 END) AS 報廢中,
    (SELECT COUNT(*) FROM RetiredEquipment) AS 已報廢,
    COUNT(*) AS 現役總計
FROM Equipment;

-- 各使用者的借用次數排行
SELECT mb.mName AS 使用者, mb.mRole AS 角色,
       COUNT(b.bId) AS 借用次數
FROM Member mb
LEFT JOIN BorrowRecord b ON mb.mId = b.mId
GROUP BY mb.mId, mb.mName, mb.mRole
ORDER BY 借用次數 DESC;


-- =============================================
-- 九、已報廢設備歷史紀錄追溯（透過 ePropertyNo）
-- =============================================

-- 查詢某筆維護紀錄對應的設備，即使設備已報廢也能找到
-- （eId 為 NULL 時改用 ePropertyNo 對照 RetiredEquipment）
SELECT m.mRecId, m.ePropertyNo,
       COALESCE(e.eName, re.eName) AS 設備名稱,
       m.mIssue, m.mStatus,
       CASE WHEN e.eId IS NOT NULL THEN '現役'
            WHEN re.eId IS NOT NULL THEN '已報廢'
            ELSE '查無資料' END AS 設備現況
FROM MaintenanceRecord m
LEFT JOIN Equipment e        ON m.eId = e.eId
LEFT JOIN RetiredEquipment re ON m.ePropertyNo = re.ePropertyNo
WHERE m.eId IS NULL;  -- 只看設備已報廢的維護紀錄

-- 查詢某台已報廢設備的完整歷程（借用+維護+報廢原因）
-- 以 ePropertyNo = 'EQ2026005' 為例
SELECT '借用紀錄' AS 類型, b.bId AS 編號, b.bStartDate AS 日期, b.bStatus AS 狀態
FROM BorrowRecord b WHERE b.ePropertyNo = 'EQ2026005'
UNION ALL
SELECT '維護紀錄' AS 類型, m.mRecId AS 編號, m.mRecDate AS 日期, m.mStatus AS 狀態
FROM MaintenanceRecord m WHERE m.ePropertyNo = 'EQ2026005'
UNION ALL
SELECT '報廢歸檔' AS 類型, re.eId AS 編號, re.retiredDate AS 日期, '已報廢' AS 狀態
FROM RetiredEquipment re WHERE re.ePropertyNo = 'EQ2026005';
