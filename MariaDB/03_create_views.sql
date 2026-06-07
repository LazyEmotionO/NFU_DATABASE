-- =============================================
-- 資工系設備管理與維護系統
-- 03_create_views.sql - 建立檢視表
-- =============================================

USE nfu;

-- 清除舊 View（若存在）
DROP VIEW IF EXISTS v_available_equipment;
DROP VIEW IF EXISTS v_borrowed_equipment;
DROP VIEW IF EXISTS v_pending_maintenance;
DROP VIEW IF EXISTS v_pending_retire;
DROP VIEW IF EXISTS v_equipment_full;


-- =============================================
-- View 1：v_available_equipment 目前可借用的設備
-- 用途：教師/學生查詢可借用設備清單
-- =============================================
CREATE VIEW v_available_equipment AS
SELECT
    e.eId,
    e.ePropertyNo   AS 財產編號,
    e.eName         AS 設備名稱,
    c.cName         AS 類別,
    e.eLocation     AS 存放地點,
    e.eWarrantyDate AS 保固到期日
FROM Equipment e
JOIN Category c ON e.cId = c.cId
WHERE e.eStatus = '可用';


-- =============================================
-- View 2：v_borrowed_equipment 目前借出中的設備（含借用人）
-- 用途：管理員掌握設備借出狀況
-- =============================================
CREATE VIEW v_borrowed_equipment AS
SELECT
    b.bId,
    e.ePropertyNo   AS 財產編號,
    e.eName         AS 設備名稱,
    mb.mName        AS 借用人,
    mb.mRole        AS 借用人角色,
    b.bStartDate    AS 借用開始日,
    b.bEndDate      AS 應還日期,
    b.bStatus       AS 借用狀態
FROM BorrowRecord b
JOIN Equipment e  ON b.eId = e.eId
JOIN Member mb    ON b.mId = mb.mId
WHERE b.bStatus IN ('核准', '逾期');


-- =============================================
-- View 3：v_pending_maintenance 待處理的維護紀錄
-- 用途：管理員快速掌握待處理維護工單
-- =============================================
CREATE VIEW v_pending_maintenance AS
SELECT
    m.mRecId,
    e.ePropertyNo   AS 財產編號,
    e.eName         AS 設備名稱,
    e.eLocation     AS 設備地點,
    mb.mName        AS 申報人,
    m.mRecDate      AS 申報日期,
    m.mIssue        AS 問題描述,
    m.mStatus       AS 維護狀態
FROM MaintenanceRecord m
JOIN Equipment e ON m.eId = e.eId
JOIN Member mb   ON m.mId = mb.mId
WHERE m.mStatus IN ('待處理', '處理中');


-- =============================================
-- View 4：v_pending_retire 待審核的報廢申請
-- 用途：管理員審核報廢申請
-- =============================================
CREATE VIEW v_pending_retire AS
SELECT
    r.retId,
    e.ePropertyNo   AS 財產編號,
    e.eName         AS 設備名稱,
    e.eLocation     AS 設備地點,
    mb.mName        AS 申請人,
    r.retDate       AS 申請日期,
    r.retReason     AS 報廢原因,
    r.retStatus     AS 審核狀態
FROM RetirementRequest r
JOIN Equipment e ON r.eId = e.eId
JOIN Member mb   ON r.mId = mb.mId
WHERE r.retStatus = '待審核';


-- =============================================
-- View 5：v_equipment_full 設備完整資訊（含類別名稱）
-- 用途：所有使用者查詢設備詳細資訊
-- =============================================
CREATE VIEW v_equipment_full AS
SELECT
    e.eId,
    e.ePropertyNo   AS 財產編號,
    e.eName         AS 設備名稱,
    c.cName         AS 類別名稱,
    c.cOutline      AS 類別說明,
    e.eStatus       AS 設備狀態,
    e.eLocation     AS 存放地點,
    e.ePurchaseDate AS 購入日期,
    e.eWarrantyDate AS 保固到期日,
    e.eNote         AS 備註
FROM Equipment e
JOIN Category c ON e.cId = c.cId;


-- =============================================
-- 確認 View 建立完成
-- =============================================
SHOW FULL TABLES WHERE Table_type = 'VIEW';
