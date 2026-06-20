-- =============================================
-- 資工系設備管理與維護系統
-- 03_create_views.sql - 建立檢視表（v4）
-- 設計方向：依使用者角色設計「視角型」View
--   - 管理員視角：總覽待處理事項、設備總覽、已報廢設備
--   - 學生/教師視角：可借設備、我的借用/維護/報廢紀錄
-- =============================================

USE nfu;

-- 清除舊 View（若存在）
DROP VIEW IF EXISTS v_admin_dashboard_pending;
DROP VIEW IF EXISTS v_admin_equipment_overview;
DROP VIEW IF EXISTS v_admin_retired_equipment;
DROP VIEW IF EXISTS v_user_available_equipment;
DROP VIEW IF EXISTS v_user_my_borrows;
DROP VIEW IF EXISTS v_user_my_maintenance;
DROP VIEW IF EXISTS v_user_my_retirements;


-- =====================================================
-- 【管理員視角】View 1：待處理事項總覽
-- 用途：管理員登入後，一次看到所有待審核/待處理事項
--       （借用申請、維護工單、報廢申請）
-- =====================================================
CREATE VIEW v_admin_dashboard_pending AS
SELECT
    '借用申請' AS 事項類型,
    b.bId AS 編號,
    mb.mName AS 申請人,
    e.eName AS 設備名稱,
    b.bApplyDate AS 申請日期,
    b.bStatus AS 狀態
FROM BorrowRecord b
JOIN Member mb ON b.mId = mb.mId
LEFT JOIN Equipment e ON b.eId = e.eId
WHERE b.bStatus = '申請中'

UNION ALL

SELECT
    '維護工單' AS 事項類型,
    m.mRecId AS 編號,
    mb.mName AS 申請人,
    e.eName AS 設備名稱,
    m.mRecDate AS 申請日期,
    m.mStatus AS 狀態
FROM MaintenanceRecord m
JOIN Member mb ON m.mId = mb.mId
LEFT JOIN Equipment e ON m.eId = e.eId
WHERE m.mStatus IN ('待處理', '處理中')

UNION ALL

SELECT
    '報廢申請' AS 事項類型,
    r.retId AS 編號,
    mb.mName AS 申請人,
    e.eName AS 設備名稱,
    r.retDate AS 申請日期,
    r.retStatus AS 狀態
FROM RetirementRequest r
JOIN Member mb ON r.mId = mb.mId
LEFT JOIN Equipment e ON r.eId = e.eId
WHERE r.retStatus = '待審核';


-- =====================================================
-- 【管理員視角】View 2：設備總覽
-- 用途：管理員查看所有現役設備的完整資訊與類別
-- =====================================================
CREATE VIEW v_admin_equipment_overview AS
SELECT
    e.eId,
    CONCAT(c.cCode, '-', e.eSN) AS 完整財編,
    e.eSN         AS 序號,
    e.eName       AS 設備名稱,
    c.cName       AS 類別名稱,
    e.eStatus     AS 設備狀態,
    e.eLocation   AS 存放地點,
    e.ePurchaseDate AS 購入日期,
    e.eWarrantyDate AS 保固到期日,
    e.eNote       AS 備註
FROM Equipment e
JOIN Category c ON e.cId = c.cId;


-- =====================================================
-- 【管理員視角】View 3：已報廢設備列表
-- 用途：管理員查看歷史報廢紀錄與歸檔資訊
-- =====================================================
CREATE VIEW v_admin_retired_equipment AS
SELECT
    re.eId,
    CONCAT(c.cCode, '-', re.eSN) AS 完整財編,
    re.eSN        AS 序號,
    re.eName      AS 設備名稱,
    c.cName       AS 類別名稱,
    re.eLocation  AS 原存放地點,
    re.retReason  AS 報廢原因,
    mb.mName      AS 審核人,
    re.retiredDate AS 報廢日期
FROM RetiredEquipment re
JOIN Category c ON re.cId = c.cId
JOIN Member mb  ON re.retApprovedBy = mb.mId;


-- =====================================================
-- 【學生/教師視角】View 4：目前可借用設備
-- 用途：教師/學生瀏覽可借用設備清單
-- =====================================================
CREATE VIEW v_user_available_equipment AS
SELECT
    e.eId,
    CONCAT(c.cCode, '-', e.eSN) AS 完整財編,
    e.eName         AS 設備名稱,
    c.cName         AS 類別,
    e.eLocation     AS 存放地點,
    e.eWarrantyDate AS 保固到期日
FROM Equipment e
JOIN Category c ON e.cId = c.cId
WHERE e.eStatus = '可用';


-- =====================================================
-- 【學生/教師視角】View 5：我的借用紀錄
-- 用途：使用者查詢自己歷史與目前的借用申請狀態
-- 使用方式：WHERE 我的mId = <登入者 mId>
-- =====================================================
CREATE VIEW v_user_my_borrows AS
SELECT
    b.mId           AS 我的mId,
    b.bId,
    b.ePropertyNo   AS 財產編號,
    COALESCE(e.eName, '(設備已報廢)') AS 設備名稱,
    b.bApplyDate    AS 申請日期,
    b.bStartDate    AS 借用開始日,
    b.bEndDate      AS 應還日期,
    b.bReturnDate   AS 實際歸還日,
    b.bStatus       AS 狀態,
    b.bRejectReason AS 拒絕原因
FROM BorrowRecord b
LEFT JOIN Equipment e ON b.eId = e.eId;


-- =====================================================
-- 【學生/教師視角】View 6：我的維護申報紀錄
-- 用途：使用者查詢自己提出的維護申報進度
-- 使用方式：WHERE 我的mId = <登入者 mId>
-- =====================================================
CREATE VIEW v_user_my_maintenance AS
SELECT
    m.mId           AS 我的mId,
    m.mRecId,
    m.ePropertyNo   AS 財產編號,
    COALESCE(e.eName, '(設備已報廢)') AS 設備名稱,
    m.mRecDate      AS 申報日期,
    m.mIssue        AS 問題描述,
    m.mResult       AS 處理結果,
    m.mStatus       AS 維護狀態,
    m.mRejectReason AS 拒絕原因
FROM MaintenanceRecord m
LEFT JOIN Equipment e ON m.eId = e.eId;


-- =====================================================
-- 【學生/教師視角】View 7：我的報廢申請紀錄
-- 用途：使用者查詢自己提出的報廢申請審核進度
-- 使用方式：WHERE 我的mId = <登入者 mId>
-- =====================================================
CREATE VIEW v_user_my_retirements AS
SELECT
    r.mId           AS 我的mId,
    r.retId,
    r.eId,
    r.ePropertyNo   AS 財產編號,
    COALESCE(e.eName, re.eName, '(查無資料)') AS 設備名稱,
    r.retDate       AS 申請日期,
    r.retReason     AS 報廢原因,
    r.retStatus     AS 審核狀態,
    r.retRejectReason AS 駁回原因
FROM RetirementRequest r
LEFT JOIN Equipment e ON r.eId = e.eId
LEFT JOIN RetiredEquipment re ON r.ePropertyNo = CONCAT(
    (SELECT c.cCode FROM Category c WHERE c.cId = re.cId),
    '-', re.eSN
);


-- =============================================
-- 確認 View 建立完成
-- =============================================
SHOW FULL TABLES WHERE Table_type = 'VIEW';
