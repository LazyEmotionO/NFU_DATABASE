-- =============================================
-- 外鍵測試 - 所有測試都應該報錯
-- =============================================

USE nfu;

-- =============================================
-- 測試 1：Equipment.cId → Category.cId
-- 插入一個不存在的 cId=99
-- =============================================
SELECT '測試1：Equipment.cId FK（應報錯）' AS 測試項目;
INSERT INTO Equipment (ePropertyNo, eName, cId, eStatus, eLocation, ePurchaseDate)
VALUES ('EQ9999', '測試設備', 99, '可用', 'A棟101室', '2026-01-01');

-- =============================================
-- 測試 2：BorrowRecord.mId → Member.mId
-- 插入一個不存在的 mId=99
-- =============================================
SELECT '測試2：BorrowRecord.mId FK（應報錯）' AS 測試項目;
INSERT INTO BorrowRecord (mId, eId, bApplyDate, bStartDate, bEndDate, bStatus)
VALUES (99, 1, '2026-05-01', '2026-05-02', '2026-05-10', '申請中');

-- =============================================
-- 測試 3：BorrowRecord.eId → Equipment.eId
-- 插入一個不存在的 eId=99
-- =============================================
SELECT '測試3：BorrowRecord.eId FK（應報錯）' AS 測試項目;
INSERT INTO BorrowRecord (mId, eId, bApplyDate, bStartDate, bEndDate, bStatus)
VALUES (1, 99, '2026-05-01', '2026-05-02', '2026-05-10', '申請中');

-- =============================================
-- 測試 4：BorrowRecord.bApprovedBy → Member.mId
-- 插入一個不存在的 bApprovedBy=99
-- =============================================
SELECT '測試4：BorrowRecord.bApprovedBy FK（應報錯）' AS 測試項目;
INSERT INTO BorrowRecord (mId, eId, bApplyDate, bApprovedBy, bStartDate, bEndDate, bStatus)
VALUES (1, 1, '2026-05-01', 99, '2026-05-02', '2026-05-10', '核准');

-- =============================================
-- 測試 5：MaintenanceRecord.eId → Equipment.eId
-- 插入一個不存在的 eId=99
-- =============================================
SELECT '測試5：MaintenanceRecord.eId FK（應報錯）' AS 測試項目;
INSERT INTO MaintenanceRecord (eId, mId, mRecDate, mIssue, mStatus)
VALUES (99, 1, '2026-05-01', '測試問題', '待處理');

-- =============================================
-- 測試 6：MaintenanceRecord.mId → Member.mId
-- 插入一個不存在的 mId=99
-- =============================================
SELECT '測試6：MaintenanceRecord.mId FK（應報錯）' AS 測試項目;
INSERT INTO MaintenanceRecord (eId, mId, mRecDate, mIssue, mStatus)
VALUES (1, 99, '2026-05-01', '測試問題', '待處理');

-- =============================================
-- 測試 7：RetirementRequest.eId → Equipment.eId
-- 插入一個不存在的 eId=99
-- =============================================
SELECT '測試7：RetirementRequest.eId FK（應報錯）' AS 測試項目;
INSERT INTO RetirementRequest (eId, mId, retDate, retReason, retStatus)
VALUES (99, 1, '2026-05-01', '測試報廢', '待審核');

-- =============================================
-- 測試 8：RetirementRequest.mId → Member.mId
-- 插入一個不存在的 mId=99
-- =============================================
SELECT '測試8：RetirementRequest.mId FK（應報錯）' AS 測試項目;
INSERT INTO RetirementRequest (eId, mId, retDate, retReason, retStatus)
VALUES (1, 99, '2026-05-01', '測試報廢', '待審核');

-- =============================================
-- 測試 9：刪除有被參考的 Member（應報錯）
-- mId=1 被 BorrowRecord 參考
-- =============================================
SELECT '測試9：刪除被參考的 Member（應報錯）' AS 測試項目;
DELETE FROM Member WHERE mId = 1;

-- =============================================
-- 測試 10：刪除有被參考的 Equipment（應報錯）
-- eId=1 被 BorrowRecord 參考
-- =============================================
SELECT '測試10：刪除被參考的 Equipment（應報錯）' AS 測試項目;
DELETE FROM Equipment WHERE eId = 1;
