-- =============================================
-- 資工系設備管理與維護系統
-- Department Equipment Management & Maintenance System
-- Group 4 | National Formosa University
-- command.sql - 常用查詢指令
-- =============================================

USE nfu;

-- =============================================
-- 一、基本查詢
-- =============================================

-- 查詢所有使用者
SELECT * FROM Member;

-- 查詢所有設備
SELECT * FROM Equipment;

-- 查詢所有設備類別
SELECT * FROM Category;

-- 查詢所有借用紀錄
SELECT * FROM BorrowRecord;

-- 查詢所有維護紀錄
SELECT * FROM MaintenanceRecord;

-- 查詢所有報廢申請
SELECT * FROM RetirementRequest;


-- =============================================
-- 二、設備相關查詢
-- =============================================

-- 查詢目前可借用的設備
SELECT eId, ePropertyNo, eName, eLocation
FROM Equipment
WHERE eStatus = '可用';

-- 查詢目前借出中的設備
SELECT eId, ePropertyNo, eName, eLocation
FROM Equipment
WHERE eStatus = '借出中';

-- 查詢目前維修中的設備
SELECT eId, ePropertyNo, eName, eLocation, eNote
FROM Equipment
WHERE eStatus = '維修中';

-- 查詢已報廢的設備
SELECT eId, ePropertyNo, eName, eLocation, eNote
FROM Equipment
WHERE eStatus = '報廢';

-- 查詢各類別的設備數量
SELECT c.cName, COUNT(e.eId) AS 設備數量
FROM Category c
LEFT JOIN Equipment e ON c.cId = e.cId
GROUP BY c.cId, c.cName;

-- 查詢各狀態的設備數量
SELECT eStatus AS 狀態, COUNT(*) AS 數量
FROM Equipment
GROUP BY eStatus;

-- 查詢保固即將到期的設備（90天內）
SELECT eId, ePropertyNo, eName, eWarrantyDate
FROM Equipment
WHERE eWarrantyDate IS NOT NULL
  AND eWarrantyDate <= DATE_ADD(CURRENT_DATE, INTERVAL 90 DAY)
  AND eWarrantyDate >= CURRENT_DATE;


-- =============================================
-- 三、借用相關查詢
-- =============================================

-- 查詢目前逾期的借用紀錄（含借用人與設備名稱）
SELECT b.bId, mb.mName AS 借用人, e.eName AS 設備名稱,
       b.bStartDate AS 借用開始, b.bEndDate AS 應還日期
FROM BorrowRecord b
JOIN Member mb ON b.mId = mb.mId
JOIN Equipment e ON b.eId = e.eId
WHERE b.bStatus = '逾期';

-- 查詢目前核准且尚未歸還的借用紀錄
SELECT b.bId, mb.mName AS 借用人, e.eName AS 設備名稱,
       b.bStartDate AS 借用開始, b.bEndDate AS 應還日期
FROM BorrowRecord b
JOIN Member mb ON b.mId = mb.mId
JOIN Equipment e ON b.eId = e.eId
WHERE b.bStatus = '核准';

-- 查詢待審核的借用申請
SELECT b.bId, mb.mName AS 申請人, e.eName AS 設備名稱,
       b.bApplyDate AS 申請日期
FROM BorrowRecord b
JOIN Member mb ON b.mId = mb.mId
JOIN Equipment e ON b.eId = e.eId
WHERE b.bStatus = '申請中';

-- 查詢某位使用者的所有借用紀錄（以 mId=3 為例）
SELECT b.bId, e.eName AS 設備名稱, b.bStartDate,
       b.bEndDate, b.bReturnDate, b.bStatus
FROM BorrowRecord b
JOIN Equipment e ON b.eId = e.eId
WHERE b.mId = 3;

-- 查詢某項設備的借用歷程（以 eId=2 為例）
SELECT b.bId, mb.mName AS 借用人, b.bStartDate,
       b.bEndDate, b.bReturnDate, b.bStatus
FROM BorrowRecord b
JOIN Member mb ON b.mId = mb.mId
WHERE b.eId = 2;


-- =============================================
-- 四、維護相關查詢
-- =============================================

-- 查詢待處理的維護紀錄（含設備名稱與申報人）
SELECT m.mRecId, e.eName AS 設備名稱, mb.mName AS 申報人,
       m.mRecDate AS 申報日期, m.mIssue AS 問題描述
FROM MaintenanceRecord m
JOIN Equipment e  ON m.eId = e.eId
JOIN Member mb    ON m.mId = mb.mId
WHERE m.mStatus = '待處理';

-- 查詢處理中的維護紀錄
SELECT m.mRecId, e.eName AS 設備名稱, mb.mName AS 申報人,
       m.mRecDate AS 申報日期, m.mIssue AS 問題描述, m.mStaff AS 負責人員
FROM MaintenanceRecord m
JOIN Equipment e  ON m.eId = e.eId
JOIN Member mb    ON m.mId = mb.mId
WHERE m.mStatus = '處理中';

-- 查詢某項設備的完整維護歷程（以 eId=3 為例）
SELECT m.mRecId, mb.mName AS 申報人, m.mRecDate,
       m.mIssue AS 問題描述, m.mResult AS 處理結果,
       m.mStaff AS 負責人員, m.mStatus AS 狀態
FROM MaintenanceRecord m
JOIN Member mb ON m.mId = mb.mId
WHERE m.eId = 3
ORDER BY m.mRecDate;

-- 查詢各設備的維護次數
SELECT e.eName AS 設備名稱, COUNT(m.mRecId) AS 維護次數
FROM Equipment e
LEFT JOIN MaintenanceRecord m ON e.eId = m.eId
GROUP BY e.eId, e.eName
ORDER BY 維護次數 DESC;


-- =============================================
-- 五、報廢相關查詢
-- =============================================

-- 查詢待審核的報廢申請（含設備名稱與申請人）
SELECT r.retId, e.eName AS 設備名稱, mb.mName AS 申請人,
       r.retDate AS 申請日期, r.retReason AS 報廢原因
FROM RetirementRequest r
JOIN Equipment e ON r.eId = e.eId
JOIN Member mb   ON r.mId = mb.mId
WHERE r.retStatus = '待審核';

-- 查詢已核准的報廢申請
SELECT r.retId, e.eName AS 設備名稱, mb.mName AS 申請人,
       r.retDate AS 申請日期, r.retReason AS 報廢原因
FROM RetirementRequest r
JOIN Equipment e ON r.eId = e.eId
JOIN Member mb   ON r.mId = mb.mId
WHERE r.retStatus = '核准';

-- 查詢某項設備的所有報廢申請紀錄（以 eId=5 為例）
SELECT r.retId, mb.mName AS 申請人, r.retDate,
       r.retReason AS 報廢原因, r.retStatus AS 審核狀態
FROM RetirementRequest r
JOIN Member mb ON r.mId = mb.mId
WHERE r.eId = 5;


-- =============================================
-- 六、統計報表查詢
-- =============================================

-- 設備狀態總覽
SELECT
    SUM(CASE WHEN eStatus = '可用'   THEN 1 ELSE 0 END) AS 可用,
    SUM(CASE WHEN eStatus = '借出中' THEN 1 ELSE 0 END) AS 借出中,
    SUM(CASE WHEN eStatus = '維修中' THEN 1 ELSE 0 END) AS 維修中,
    SUM(CASE WHEN eStatus = '報廢'   THEN 1 ELSE 0 END) AS 報廢,
    COUNT(*) AS 總計
FROM Equipment;

-- 各使用者的借用次數排行
SELECT mb.mName AS 使用者, mb.mRole AS 角色,
       COUNT(b.bId) AS 借用次數
FROM Member mb
LEFT JOIN BorrowRecord b ON mb.mId = b.mId
GROUP BY mb.mId, mb.mName, mb.mRole
ORDER BY 借用次數 DESC;

-- 各使用者的維護申報次數
SELECT mb.mName AS 使用者, COUNT(m.mRecId) AS 申報次數
FROM Member mb
LEFT JOIN MaintenanceRecord m ON mb.mId = m.mId
GROUP BY mb.mId, mb.mName
ORDER BY 申報次數 DESC;
