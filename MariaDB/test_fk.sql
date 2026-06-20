-- =============================================
-- 外鍵、CHECK 與業務規則測試（v5）
-- =============================================

USE nfu;

-- =============================================
-- 測試 1：Equipment.cId → Category.cId（應報錯 1452）
-- =============================================
SELECT '測試1：Equipment.cId FK（應報錯）' AS 測試項目;
INSERT INTO Equipment (eSN, eName, cId, eStatus, eLocation, ePurchaseDate)
VALUES ('9999999', '測試設備', 99, '可用', 'A棟101室', '2026-01-01');

-- =============================================
-- 測試 2：mEmail 非 @nfu.edu.tw（應報錯）
-- =============================================
SELECT '測試2：mEmail 非 @nfu.edu.tw（應報錯）' AS 測試項目;
INSERT INTO Member (mAccount, mName, mEmail, mRole)
VALUES ('test001', '測試使用者', 'test001@gmail.com', '學生');

-- =============================================
-- 測試 3：cCode 格式錯誤（應報錯）
-- =============================================
SELECT '測試3：cCode 格式錯誤（應報錯）' AS 測試項目;
INSERT INTO Category (cCode, cName) VALUES ('ABCDEFG-01', '測試類別');

-- =============================================
-- 測試 4：刪除被 BorrowRecord 參考的 Member（應報錯 1451）
-- =============================================
SELECT '測試4：刪除被參考的 Member（應報錯）' AS 測試項目;
DELETE FROM Member WHERE mId = 1;

-- =============================================
-- 測試 5：刪除被 Equipment 參考的 Category（應報錯 1451）
-- =============================================
SELECT '測試5：刪除被參考的 Category（應報錯）' AS 測試項目;
DELETE FROM Category WHERE cId = 1;

-- =============================================
-- 測試 6：對「非可用」設備提出借用申請（應報錯）
-- eId=1（筆記型電腦）目前狀態為「借出中」（逾期未還）
-- =============================================
SELECT '測試6：對非可用設備提出借用申請（應報錯）' AS 測試項目;
SELECT eId, eSN, eStatus FROM Equipment WHERE eId = 1;
INSERT INTO BorrowRecord (mId, eId, bApplyDate, bStartDate, bEndDate, bStatus)
VALUES (5, 1, '2026-06-01', '2026-06-02', '2026-06-10', '申請中');

-- =============================================
-- 測試 7：對「非可用」設備提出維護申報（應報錯）
-- eId=7（伺服器）目前狀態為「借出中」
-- =============================================
SELECT '測試7：對非可用設備提出維護申報（應報錯）' AS 測試項目;
SELECT eId, eSN, eStatus FROM Equipment WHERE eId = 7;
INSERT INTO MaintenanceRecord (eId, mId, mRecDate, mIssue, mStatus)
VALUES (7, 2, '2026-06-01', '測試問題', '待處理');

-- =============================================
-- 測試 8：對「非可用」設備提出報廢申請（應報錯）
-- eId=9（網路儲存設備）目前狀態為「維修中」
-- =============================================
SELECT '測試8：對非可用設備提出報廢申請（應報錯）' AS 測試項目;
SELECT eId, eSN, eStatus FROM Equipment WHERE eId = 9;
INSERT INTO RetirementRequest (eId, mId, retDate, retReason, retStatus)
VALUES (9, 1, '2026-06-01', '測試報廢', '待審核');

-- =============================================
-- 測試 9：正常流程 - 借用申請鎖定設備
-- eId=3（網路交換器）目前「可用」
-- =============================================
SELECT '測試9：借用申請鎖定設備（提出後應變借出中）' AS 測試項目;
SELECT eId, eSN, eStatus FROM Equipment WHERE eId = 3;

INSERT INTO BorrowRecord (bId, mId, eId, bApplyDate, bStartDate, bEndDate, bStatus)
VALUES (100, 5, 3, '2026-06-01', '2026-06-02', '2026-06-10', '申請中');

SELECT '提出申請後 Equipment#3 應變為「借出中」，ePropertyNo 自動帶入完整財編' AS 結果;
SELECT eId, eStatus FROM Equipment WHERE eId = 3;
SELECT bId, ePropertyNo, bStatus FROM BorrowRecord WHERE bId = 100;

UPDATE BorrowRecord SET bStatus='拒絕', bApprovedBy=1, bApprovedDate='2026-06-02',
       bRejectReason='測試用拒絕' WHERE bId=100;

SELECT '拒絕後 Equipment#3 應恢復為「可用」' AS 結果;
SELECT eId, eStatus FROM Equipment WHERE eId = 3;

DELETE FROM BorrowRecord WHERE bId = 100;


-- =============================================
-- 測試 10：報廢核准 Trigger 搬移驗證
-- eId=3（網路交換器）目前「可用」
-- =============================================
SELECT '測試10：報廢核准前 - Equipment 與 RetiredEquipment 數量' AS 測試項目;
SELECT COUNT(*) AS Equipment總數 FROM Equipment;
SELECT COUNT(*) AS RetiredEquipment總數 FROM RetiredEquipment;

INSERT INTO RetirementRequest (retId, eId, mId, retDate, retReason, retStatus)
VALUES (100, 3, 1, '2026-06-01', '測試報廢搬移', '待審核');

SELECT '提出報廢後 Equipment#3 應變為「報廢中」，ePropertyNo 自動帶入' AS 結果;
SELECT eId, eStatus FROM Equipment WHERE eId = 3;
SELECT retId, ePropertyNo, retStatus FROM RetirementRequest WHERE retId = 100;

UPDATE RetirementRequest SET retStatus='核准', retApprovedBy=1 WHERE retId=100;

SELECT '核准後 - Equipment 數量應減少1，RetiredEquipment 應增加1' AS 結果;
SELECT COUNT(*) AS Equipment總數 FROM Equipment;
SELECT COUNT(*) AS RetiredEquipment總數 FROM RetiredEquipment;

SELECT 'RetiredEquipment 新增內容（eId=3, 完整財編=3140307-02-0034862）' AS 結果;
SELECT re.eId, CONCAT(c.cCode, '-', re.eSN) AS 完整財編, re.eName, re.retReason, re.retiredDate
FROM RetiredEquipment re JOIN Category c ON re.cId = c.cId WHERE re.eId = 3;

SELECT 'MaintenanceRecord 歷史紀錄 eId 應變為 NULL，ePropertyNo 快照保留' AS 結果;
SELECT mRecId, eId, ePropertyNo, mIssue FROM MaintenanceRecord
WHERE ePropertyNo = '3140307-02-0034862';


-- =============================================
-- 測試 11：EVENT 手動觸發逾期檢查
-- =============================================
SELECT '測試11：EVENT 逾期檢查' AS 測試項目;

INSERT INTO BorrowRecord (bId, mId, eId, bApplyDate, bStartDate, bEndDate, bStatus)
VALUES (101, 5, 4, '2026-01-01', '2026-01-03', '2026-01-10', '申請中');
UPDATE BorrowRecord SET bStatus='核准', bApprovedBy=1, bApprovedDate='2026-01-02' WHERE bId=101;

SELECT '執行前（bEndDate 已過，但仍是核准）：' AS '';
SELECT bId, ePropertyNo, bEndDate, bStatus FROM BorrowRecord WHERE bId = 101;

UPDATE BorrowRecord
   SET bStatus = '逾期'
 WHERE bStatus = '核准'
   AND bEndDate < CURRENT_DATE;

SELECT '執行後（應變為逾期）：' AS '';
SELECT bId, bEndDate, bStatus FROM BorrowRecord WHERE bId = 101;

UPDATE BorrowRecord SET bStatus='已歸還', bReturnDate=CURRENT_DATE WHERE bId=101;
DELETE FROM BorrowRecord WHERE bId = 101;

SELECT '清除後 Equipment#4 應恢復「可用」' AS '';
SELECT eId, eStatus FROM Equipment WHERE eId = 4;


-- =============================================
-- 確認 EVENT 已建立並啟用
-- =============================================
SELECT '=== EVENT 設定確認 ===' AS '';
SHOW EVENTS;
