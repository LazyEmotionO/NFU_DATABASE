-- =============================================
-- 資工系設備管理與維護系統
-- test_triggers.sql
-- =============================================

USE nfu;


-- =============================================
-- 測試 1：借用申請鎖定設備（trg_borrow_before/after_insert）
-- eId=3（網路交換器）目前「可用」
-- =============================================
SELECT '測試1-前置：Equipment#3 應為「可用」' AS 測試項目;
SELECT eId, eSN, eStatus FROM Equipment WHERE eId = 3;

INSERT INTO BorrowRecord (bId, mId, eId, bApplyDate, bStartDate, bEndDate, bStatus)
VALUES (101, 5, 3, '2026-06-01', '2026-06-02', '2026-06-10', '申請中');

SELECT '測試1-結果：提出申請後 Equipment#3 應變為「借出中」，ePropertyNo 應自動填入' AS 測試項目;
SELECT eId, eStatus FROM Equipment WHERE eId = 3;
SELECT bId, ePropertyNo, bStatus FROM BorrowRecord WHERE bId = 101;


-- =============================================
-- 測試 2：對「非可用」設備提出借用申請（應報錯）
-- eId=3 此時已是「借出中」
-- =============================================
SELECT '測試2：對非可用設備(eId=3)提出借用申請（應報錯）' AS 測試項目;
INSERT INTO BorrowRecord (mId, eId, bApplyDate, bStartDate, bEndDate, bStatus)
VALUES (6, 3, '2026-06-02', '2026-06-03', '2026-06-11', '申請中');


-- =============================================
-- 測試 3：對「非可用」設備提出維護申報（應報錯）
-- =============================================
SELECT '測試3：對非可用設備(eId=3)提出維護申報（應報錯）' AS 測試項目;
INSERT INTO MaintenanceRecord (eId, mId, mRecDate, mIssue, mStatus)
VALUES (3, 2, '2026-06-02', '測試問題', '待處理');


-- =============================================
-- 測試 4：對「非可用」設備提出報廢申請（應報錯）
-- =============================================
SELECT '測試4：對非可用設備(eId=3)提出報廢申請（應報錯）' AS 測試項目;
INSERT INTO RetirementRequest (eId, mId, retDate, retReason, retStatus)
VALUES (3, 1, '2026-06-02', '測試報廢', '待審核');


-- =============================================
-- 測試 5：借用拒絕後設備恢復可用（trg_borrow_result）
-- =============================================
UPDATE BorrowRecord SET bStatus='拒絕', bApprovedBy=1, bApprovedDate='2026-06-02',
       bRejectReason='測試用拒絕' WHERE bId=101;

SELECT '測試5-結果：拒絕後 Equipment#3 應恢復為「可用」' AS 測試項目;
SELECT eId, eStatus FROM Equipment WHERE eId = 3;

DELETE FROM BorrowRecord WHERE bId = 101;


-- =============================================
-- 測試 6：借用核准→歸還，設備恢復可用（trg_borrow_result）
-- =============================================
SELECT '測試6-前置：Equipment#3 應為「可用」' AS 測試項目;
SELECT eId, eStatus FROM Equipment WHERE eId = 3;

INSERT INTO BorrowRecord (bId, mId, eId, bApplyDate, bStartDate, bEndDate, bStatus)
VALUES (102, 5, 3, '2026-06-01', '2026-06-02', '2026-06-10', '申請中');

SELECT '測試6-中間：核准後 Equipment#3 應維持「借出中」' AS 測試項目;
UPDATE BorrowRecord SET bStatus='核准', bApprovedBy=1, bApprovedDate='2026-06-02' WHERE bId=102;
SELECT eId, eStatus FROM Equipment WHERE eId = 3;

UPDATE BorrowRecord SET bStatus='已歸還', bReturnDate='2026-06-09' WHERE bId=102;

SELECT '測試6-結果：歸還後 Equipment#3 應恢復為「可用」' AS 測試項目;
SELECT eId, eStatus FROM Equipment WHERE eId = 3;

DELETE FROM BorrowRecord WHERE bId = 102;


-- =============================================
-- 測試 7：維護申報鎖定、拒絕後恢復可用（trg_maintenance_*）
-- =============================================
INSERT INTO MaintenanceRecord (mRecId, eId, mId, mRecDate, mIssue, mStatus)
VALUES (101, 3, 2, '2026-06-01', '測試維護', '待處理');

SELECT '測試7-中間：提出申報後 Equipment#3 應變為「維修中」，ePropertyNo 應自動填入' AS 測試項目;
SELECT eId, eStatus FROM Equipment WHERE eId = 3;
SELECT mRecId, ePropertyNo, mStatus FROM MaintenanceRecord WHERE mRecId = 101;

UPDATE MaintenanceRecord SET mStatus='拒絕', mStaff='測試技師',
       mRejectReason='測試用拒絕' WHERE mRecId=101;

SELECT '測試7-結果：拒絕後 Equipment#3 應恢復為「可用」' AS 測試項目;
SELECT eId, eStatus FROM Equipment WHERE eId = 3;

DELETE FROM MaintenanceRecord WHERE mRecId = 101;


-- =============================================
-- 測試 8：維護處理中→已完成，設備恢復可用（trg_maintenance_result）
-- =============================================
INSERT INTO MaintenanceRecord (mRecId, eId, mId, mRecDate, mIssue, mStatus)
VALUES (102, 3, 2, '2026-06-01', '測試維護2', '待處理');

UPDATE MaintenanceRecord SET mStatus='處理中', mStaff='測試技師' WHERE mRecId=102;

SELECT '測試8-中間：處理中 Equipment#3 應維持「維修中」' AS 測試項目;
SELECT eId, eStatus FROM Equipment WHERE eId = 3;

UPDATE MaintenanceRecord SET mStatus='已完成', mResult='測試完成' WHERE mRecId=102;

SELECT '測試8-結果：已完成後 Equipment#3 應恢復為「可用」' AS 測試項目;
SELECT eId, eStatus FROM Equipment WHERE eId = 3;

DELETE FROM MaintenanceRecord WHERE mRecId = 102;


-- =============================================
-- 測試 9：報廢申請鎖定、駁回後恢復可用（trg_retirement_*）
-- =============================================
INSERT INTO RetirementRequest (retId, eId, mId, retDate, retReason, retStatus)
VALUES (101, 3, 1, '2026-06-01', '測試報廢', '待審核');

SELECT '測試9-中間：提出報廢後 Equipment#3 應變為「報廢中」，ePropertyNo 應自動填入' AS 測試項目;
SELECT eId, eStatus FROM Equipment WHERE eId = 3;
SELECT retId, ePropertyNo, retStatus FROM RetirementRequest WHERE retId = 101;

UPDATE RetirementRequest SET retStatus='駁回', retApprovedBy=1,
       retRejectReason='測試用駁回' WHERE retId=101;

SELECT '測試9-結果：駁回後 Equipment#3 應恢復為「可用」' AS 測試項目;
SELECT eId, eStatus FROM Equipment WHERE eId = 3;


-- =============================================
-- 測試 10：報廢核准後自動搬移（trg_retirement_approved）
-- =============================================
SELECT '測試10-前置：Equipment / RetiredEquipment 數量' AS 測試項目;
SELECT COUNT(*) AS Equipment總數 FROM Equipment;
SELECT COUNT(*) AS RetiredEquipment總數 FROM RetiredEquipment;

INSERT INTO RetirementRequest (retId, eId, mId, retDate, retReason, retStatus)
VALUES (102, 3, 1, '2026-06-05', '測試報廢搬移', '待審核');

SELECT '測試10-中間：提出報廢後 Equipment#3 應變為「報廢中」' AS 測試項目;
SELECT eId, eStatus FROM Equipment WHERE eId = 3;

UPDATE RetirementRequest SET retStatus='核准', retApprovedBy=1 WHERE retId=102;

SELECT '測試10-結果：核准後 Equipment 數量應減少1，RetiredEquipment 應增加1' AS 測試項目;
SELECT COUNT(*) AS Equipment總數 FROM Equipment;
SELECT COUNT(*) AS RetiredEquipment總數 FROM RetiredEquipment;

SELECT 'RetiredEquipment 新增內容（eId=3, 完整財編應為 3140307-02-0034862）' AS 測試項目;
SELECT re.eId, CONCAT(c.cCode, '-', re.eSN) AS 完整財編, re.eName, re.retReason, re.retiredDate
FROM RetiredEquipment re JOIN Category c ON re.cId = c.cId WHERE re.eId = 3;

SELECT 'MaintenanceRecord 中 ePropertyNo=3140307-02-0034862 的歷史紀錄 eId 應變為 NULL（快照保留）' AS 測試項目;
SELECT mRecId, eId, ePropertyNo, mIssue, mStatus
FROM MaintenanceRecord WHERE ePropertyNo = '3140307-02-0034862';

SELECT 'RetirementRequest #3（駁回紀錄）eId 應變為 NULL，ePropertyNo 快照保留' AS 測試項目;
SELECT retId, eId, ePropertyNo, retStatus FROM RetirementRequest WHERE retId IN (3, 101, 102);


-- =============================================
-- 測試 11：EVENT 逾期自動標記（evt_check_overdue_borrow）
-- =============================================
SELECT '測試11-前置：建立一筆已超過 bEndDate 但狀態仍為「核准」的借用' AS 測試項目;

INSERT INTO BorrowRecord (bId, mId, eId, bApplyDate, bStartDate, bEndDate, bStatus)
VALUES (103, 5, 4, '2026-01-01', '2026-01-03', '2026-01-10', '申請中');
UPDATE BorrowRecord SET bStatus='核准', bApprovedBy=1, bApprovedDate='2026-01-02' WHERE bId=103;

SELECT '測試11-中間：執行前狀態（bEndDate 已過，但仍是核准）' AS 測試項目;
SELECT bId, ePropertyNo, bEndDate, bStatus FROM BorrowRecord WHERE bId = 103;

UPDATE BorrowRecord
   SET bStatus = '逾期'
 WHERE bStatus = '核准'
   AND bEndDate < CURRENT_DATE;

SELECT '測試11-結果：bId=103 應變為「逾期」' AS 測試項目;
SELECT bId, bEndDate, bStatus FROM BorrowRecord WHERE bId = 103;

UPDATE BorrowRecord SET bStatus='已歸還', bReturnDate=CURRENT_DATE WHERE bId=103;
DELETE FROM BorrowRecord WHERE bId = 103;

SELECT '測試11-清除後：Equipment#4 應恢復「可用」' AS 測試項目;
SELECT eId, eStatus FROM Equipment WHERE eId = 4;


-- =============================================
-- 測試 12：確認 EVENT 已啟用
-- =============================================
SELECT '測試12：EVENT 設定確認（Status 應為 ENABLED）' AS 測試項目;
SHOW EVENTS;


-- =============================================
-- 測試 13：FK 完整性測試
-- =============================================

SELECT '測試13a：Equipment.cId 參考不存在的 Category（應報錯1452）' AS 測試項目;
INSERT INTO Equipment (eSN, eName, cId, eStatus, eLocation, ePurchaseDate)
VALUES ('9999999', '測試設備', 99, '可用', 'A棟101室', '2026-01-01');

SELECT '測試13b：mEmail 非 @nfu.edu.tw（應報錯）' AS 測試項目;
INSERT INTO Member (mAccount, mName, mEmail, mRole)
VALUES ('testuser', '測試使用者', 'testuser@gmail.com', '學生');

SELECT '測試13c：cCode 格式錯誤（應報錯）' AS 測試項目;
INSERT INTO Category (cCode, cName) VALUES ('ABCDEFG-01', '測試類別');

SELECT '測試13d：刪除被參考的 Member（應報錯1451）' AS 測試項目;
DELETE FROM Member WHERE mId = 1;


-- =============================================
-- 最終確認
-- =============================================
SELECT '=== 測試完成後最終設備狀態（eId=3 已報廢） ===' AS '';
SELECT e.eId, CONCAT(c.cCode, '-', e.eSN) AS 完整財編, e.eName, e.eStatus
FROM Equipment e JOIN Category c ON e.cId = c.cId ORDER BY e.eId;

SELECT '=== RetiredEquipment ===' AS '';
SELECT re.eId, CONCAT(c.cCode, '-', re.eSN) AS 完整財編, re.eName, re.retiredDate
FROM RetiredEquipment re JOIN Category c ON re.cId = c.cId;
