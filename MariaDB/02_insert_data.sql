-- =============================================
-- 資工系設備管理與維護系統
-- 02_insert_data.sql
-- =============================================

USE nfu;


-- =============================================
-- (1) Member
-- =============================================
INSERT INTO Member (mId, mAccount, mName, mEmail, mPhone, mRole, mCreateDate) VALUES
(1,  'B1001',    '王小明', 'wangxm@nfu.edu.tw',   '0912345678', '管理員', '2026-05-01'),
(2,  'B1025',    '李佳玲', 'teachli@nfu.edu.tw',  '0922333444', '教師',   '2026-05-02'),
(3,  '41243168', '陳冠宇', '41243168@nfu.edu.tw', '0933444555', '學生',   '2026-05-02'),
(4,  '41323125', '林怡君', '41323125@nfu.edu.tw', '0944555666', '學生',   '2026-05-03'),
(5,  'B1088',    '張志豪', 'changch@nfu.edu.tw',  '0955666777', '教師',   '2026-05-03'),
(6,  '41447135', '吳柏翰', '41447135@nfu.edu.tw', '0967112233', '學生',   '2026-05-04'),
(7,  'B1156',    '黃雅婷', 'huangyt@nfu.edu.tw',  '0978223344', '教師',   '2026-05-04'),
(8,  '41250172', '劉冠廷', '41250172@nfu.edu.tw', '0981334455', '學生',   '2026-05-05'),
(9,  'B1203',    '陳怡蓁', 'chenyz@nfu.edu.tw',   '0992445566', '管理員', '2026-05-05'),
(10, '41339141', '許家豪', '41339141@nfu.edu.tw', '0903556677', '學生',   '2026-05-06');


-- =============================================
-- (2) Category
-- =============================================
INSERT INTO Category (cId, cCode, cName, cOutline) VALUES
(1,  '3140101-03', '電腦設備',   '桌機與筆電設備'),
(2,  '3140104-05', '投影機',     '教室投影設備'),
(3,  '3140307-02', '網路設備',   '路由器與交換器'),
(4,  '3140308-01', '攝影設備',   '相機與攝影器材'),
(5,  '3140101-06', '平板設備',   '平板與行動裝置'),
(6,  '3140101-04', '顯示設備',   '螢幕與顯示器設備'),
(7,  '3140101-07', '伺服器',     '機房伺服器設備'),
(8,  '3140101-05', '周邊設備',   '鍵盤滑鼠等周邊'),
(9,  '3140307-03', '儲存設備',   'NAS與外接儲存'),
(10, '3140101-08', '實驗設備',   '嵌入式開發設備');


-- =============================================
-- (3) Equipment（全部初始為「可用」）
-- 現役 10 台 + 歷史報廢 4 台
-- =============================================
INSERT INTO Equipment (eId, eSN, eName, eSpec, cId, eStatus, eLocation, ePurchaseDate, eWarrantyDate, eNote) VALUES
-- 現役設備
(1,  '0034860', '筆記型電腦',   'ASUS TUF Gaming A15 FA507',     1,  '可用', 'B棟307室', '2025-01-10', '2028-01-10', '資訊課使用'),
(2,  '0034861', '投影機',       'EPSON EB-E20',                  2,  '可用', 'A棟201室', '2024-08-01', '2027-08-01', '教室設備'),
(3,  '0034862', '網路交換器',   'Cisco Catalyst 2960-X',         3,  '可用', '機房A',    '2023-06-15', '2026-06-15', '網路異常'),
(4,  '0034863', '數位相機',     'Canon EOS R50',                 4,  '可用', '媒體教室', '2025-03-12', '2028-03-12', '攝影課程'),
(5,  '0034864', '平板電腦',     'Apple iPad Air 5',              5,  '可用', 'D棟101室', '2021-02-01', '2024-02-01', '螢幕故障'),
(6,  '0034865', '顯示器',       'Dell UltraSharp U2723QE 27吋',  6,  '可用', 'B棟305室', '2024-09-01', '2027-09-01', '程式設計教室'),
(7,  '0034866', '伺服器',       'Dell PowerEdge R550',           7,  '可用', '機房B',    '2024-03-15', '2029-03-15', '虛擬化主機'),
(8,  '0034867', '鍵盤',         'Logitech MX Keys',              8,  '可用', '系辦公室', '2025-02-10', '2027-02-10', '教師借用'),
(9,  '0034868', '網路儲存設備', 'Synology DS923+',               9,  '可用', '機房A',    '2023-11-20', '2026-11-20', '備份儲存'),
(10, '0034869', '開發板',       'STM32 Nucleo-F446RE 開發套件', 10,  '可用', '實驗室2',  '2025-04-05', '2028-04-05', 'USB介面異常'),
-- 歷史報廢設備（將透過報廢申請核准後搬移至 RetiredEquipment）
(11, '0034870', '桌上型電腦',   NULL,  1,  '可用', 'B棟301室', '2018-03-15', '2021-03-15', '主機板故障'),
(13, '0034871', '鍵盤',         NULL,  8,  '可用', '系辦公室', '2019-09-10', '2022-09-10', '多數按鍵失效'),
(15, '0034888', '平板電腦',     NULL,  5,  '可用', 'D棟101室', '2021-02-01', '2024-02-01', '螢幕老化'),
(17, '0034889', '開發板',       NULL,  10, '可用', '實驗室2',  '2025-04-05', '2028-04-05', 'USB介面異常');


-- =============================================
-- (4) BorrowRecord 第一批（已結束）
-- =============================================

-- Borrow#1：eId=2（投影機）→ 已歸還
INSERT INTO BorrowRecord (bId, mId, eId, bApplyDate, bStartDate, bEndDate, bStatus)
VALUES (1, 3, 2, '2026-05-05', '2026-05-07', '2026-05-14', '申請中');
UPDATE BorrowRecord SET bStatus='核准', bApprovedBy=1, bApprovedDate='2026-05-06' WHERE bId=1;
UPDATE BorrowRecord SET bStatus='已歸還', bReturnDate='2026-05-13' WHERE bId=1;

-- Borrow#2：eId=1（筆記型電腦）→ 已歸還
INSERT INTO BorrowRecord (bId, mId, eId, bApplyDate, bStartDate, bEndDate, bStatus)
VALUES (2, 4, 1, '2026-05-09', '2026-05-10', '2026-05-13', '申請中');
UPDATE BorrowRecord SET bStatus='核准', bApprovedBy=1, bApprovedDate='2026-05-10' WHERE bId=2;
UPDATE BorrowRecord SET bStatus='已歸還', bReturnDate='2026-05-13' WHERE bId=2;

-- Borrow#3：eId=4（數位相機）→ 拒絕
INSERT INTO BorrowRecord (bId, mId, eId, bApplyDate, bStartDate, bEndDate, bStatus)
VALUES (3, 2, 4, '2026-05-12', '2026-05-14', '2026-05-20', '申請中');
UPDATE BorrowRecord SET bStatus='拒絕', bApprovedBy=1, bApprovedDate='2026-05-13',
       bRejectReason='該時段設備已排定校務使用' WHERE bId=3;

-- Borrow#4：eId=6（顯示器）→ 已歸還
INSERT INTO BorrowRecord (bId, mId, eId, bApplyDate, bStartDate, bEndDate, bStatus)
VALUES (4, 6, 6, '2026-05-15', '2026-05-16', '2026-05-23', '申請中');
UPDATE BorrowRecord SET bStatus='核准', bApprovedBy=9, bApprovedDate='2026-05-16' WHERE bId=4;
UPDATE BorrowRecord SET bStatus='已歸還', bReturnDate='2026-05-22' WHERE bId=4;

-- Borrow#5：eId=8（鍵盤）→ 已歸還
INSERT INTO BorrowRecord (bId, mId, eId, bApplyDate, bStartDate, bEndDate, bStatus)
VALUES (5, 8, 8, '2026-05-18', '2026-05-19', '2026-05-26', '申請中');
UPDATE BorrowRecord SET bStatus='核准', bApprovedBy=9, bApprovedDate='2026-05-19' WHERE bId=5;
UPDATE BorrowRecord SET bStatus='已歸還', bReturnDate='2026-05-25' WHERE bId=5;

-- Borrow#6：eId=2（投影機）第二次 → 已歸還
INSERT INTO BorrowRecord (bId, mId, eId, bApplyDate, bStartDate, bEndDate, bStatus)
VALUES (6, 5, 2, '2026-05-18', '2026-05-19', '2026-05-22', '申請中');
UPDATE BorrowRecord SET bStatus='核准', bApprovedBy=1, bApprovedDate='2026-05-18' WHERE bId=6;
UPDATE BorrowRecord SET bStatus='已歸還', bReturnDate='2026-05-22' WHERE bId=6;

-- Borrow#8：eId=4（數位相機）第二次 → 已歸還
INSERT INTO BorrowRecord (bId, mId, eId, bApplyDate, bStartDate, bEndDate, bStatus)
VALUES (8, 10, 4, '2026-05-23', '2026-05-25', '2026-05-27', '申請中');
UPDATE BorrowRecord SET bStatus='核准', bApprovedBy=9, bApprovedDate='2026-05-24' WHERE bId=8;
UPDATE BorrowRecord SET bStatus='已歸還', bReturnDate='2026-05-27' WHERE bId=8;


-- =============================================
-- (5) MaintenanceRecord 第一批（已結束）
-- 注意：Maint#2(eId=1) 須在 Borrow#7 之前
--       Maint#6(eId=8) 須在 Borrow#10 之前
--       Maint#8(eId=7) 須在 Borrow#9 之前
--       Maint#9(eId=2) 須在 Retire#10 之前
-- =============================================

-- Maint#1：eId=3（網路交換器）→ 已完成
INSERT INTO MaintenanceRecord (mRecId, eId, mId, mRecDate, mIssue, mStatus)
VALUES (1, 3, 2, '2026-05-01', '網路連線不穩', '待處理');
UPDATE MaintenanceRecord SET mStatus='處理中', mStaff='陳技師' WHERE mRecId=1;
UPDATE MaintenanceRecord SET mStatus='已完成', mResult='更換交換模組' WHERE mRecId=1;

-- Maint#2：eId=1（筆記型電腦）→ 已完成（須在 Borrow#7 之前）
INSERT INTO MaintenanceRecord (mRecId, eId, mId, mRecDate, mIssue, mStatus)
VALUES (2, 1, 3, '2026-05-14', '筆電無法開機', '待處理');
UPDATE MaintenanceRecord SET mStatus='處理中', mStaff='李工程' WHERE mRecId=2;
UPDATE MaintenanceRecord SET mStatus='已完成', mResult='重灌系統完成' WHERE mRecId=2;

-- Maint#3：eId=4（數位相機）→ 已完成
INSERT INTO MaintenanceRecord (mRecId, eId, mId, mRecDate, mIssue, mStatus)
VALUES (3, 4, 2, '2026-05-28', '相機鏡頭異常', '待處理');
UPDATE MaintenanceRecord SET mStatus='處理中', mStaff='張技師' WHERE mRecId=3;
UPDATE MaintenanceRecord SET mStatus='已完成', mResult='更換鏡頭環完成' WHERE mRecId=3;

-- Maint#4：eId=6（顯示器）→ 拒絕
INSERT INTO MaintenanceRecord (mRecId, eId, mId, mRecDate, mIssue, mStatus)
VALUES (4, 6, 8, '2026-05-23', '螢幕閃爍', '待處理');
UPDATE MaintenanceRecord SET mStatus='拒絕', mStaff='林工程',
       mRejectReason='已確認為連接埠鬆動，請使用者自行重新插拔即可' WHERE mRecId=4;

-- Maint#6：eId=8（鍵盤）→ 已完成（須在 Borrow#10 之前）
INSERT INTO MaintenanceRecord (mRecId, eId, mId, mRecDate, mIssue, mStatus)
VALUES (6, 8, 6, '2026-05-26', '鍵盤藍牙連線異常', '待處理');
UPDATE MaintenanceRecord SET mStatus='處理中', mStaff='李技師' WHERE mRecId=6;
UPDATE MaintenanceRecord SET mStatus='已完成', mResult='重新配對藍牙後正常' WHERE mRecId=6;

-- Maint#7：eId=10（開發板）→ 已完成
INSERT INTO MaintenanceRecord (mRecId, eId, mId, mRecDate, mIssue, mStatus)
VALUES (7, 10, 7, '2026-05-11', '開發板無法辨識USB', '待處理');
UPDATE MaintenanceRecord SET mStatus='處理中', mStaff='黃技師' WHERE mRecId=7;
UPDATE MaintenanceRecord SET mStatus='已完成', mResult='更換USB模組完成' WHERE mRecId=7;

-- Maint#8：eId=7（伺服器）→ 已完成（須在 Borrow#9 之前）
INSERT INTO MaintenanceRecord (mRecId, eId, mId, mRecDate, mIssue, mStatus)
VALUES (8, 7, 2, '2026-05-15', '伺服器風扇異音', '待處理');
UPDATE MaintenanceRecord SET mStatus='處理中', mStaff='王技師' WHERE mRecId=8;
UPDATE MaintenanceRecord SET mStatus='已完成', mResult='清潔風扇並重新校正轉速' WHERE mRecId=8;

-- Maint#9：eId=2（投影機）→ 已完成（須在 Retire#10 之前）
INSERT INTO MaintenanceRecord (mRecId, eId, mId, mRecDate, mIssue, mStatus)
VALUES (9, 2, 4, '2026-05-23', '投影畫面色偏', '待處理');
UPDATE MaintenanceRecord SET mStatus='處理中', mStaff='陳技師' WHERE mRecId=9;
UPDATE MaintenanceRecord SET mStatus='已完成', mResult='校正色彩參數完成' WHERE mRecId=9;

-- Maint#10：eId=5（平板電腦）→ 拒絕
INSERT INTO MaintenanceRecord (mRecId, eId, mId, mRecDate, mIssue, mStatus)
VALUES (10, 5, 4, '2026-05-02', '螢幕無法顯示', '待處理');
UPDATE MaintenanceRecord SET mStatus='拒絕', mStaff='王維修',
       mRejectReason='經檢測並無異常' WHERE mRecId=10;


-- =============================================
-- (6) RetirementRequest 第一批（已結束）
-- 含4筆歷史設備核准報廢（retId=2,6,7,9）
-- =============================================

-- Retire#1：eId=5（平板電腦）→ 駁回
INSERT INTO RetirementRequest (retId, eId, mId, retDate, retReason, retStatus)
VALUES (1, 5, 2, '2026-05-03', '設備老舊且維修成本過高', '待審核');
UPDATE RetirementRequest SET retStatus='駁回', retApprovedBy=1,
       retRejectReason='經檢測仍可正常使用，暫不報廢' WHERE retId=1;

-- Retire#2：eId=15（平板電腦，歷史設備）→ 核准 → Trigger 搬移至 RetiredEquipment
-- retiredDate=2026-05-21，retApprovedBy=1
INSERT INTO RetirementRequest (retId, eId, mId, retDate, retReason, retStatus)
VALUES (2, 15, 2, '2026-05-20', '保護貼問題反覆發生，且面板老化嚴重', '待審核');
UPDATE RetirementRequest SET retStatus='核准', retApprovedBy=1 WHERE retId=2;

-- Retire#3：eId=3（網路交換器）→ 駁回
INSERT INTO RetirementRequest (retId, eId, mId, retDate, retReason, retStatus)
VALUES (3, 3, 1, '2026-05-08', '故障頻繁影響使用', '待審核');
UPDATE RetirementRequest SET retStatus='駁回', retApprovedBy=9,
       retRejectReason='已完成維修，功能恢復正常' WHERE retId=3;

-- Retire#4：eId=6（顯示器）→ 駁回
INSERT INTO RetirementRequest (retId, eId, mId, retDate, retReason, retStatus)
VALUES (4, 6, 1, '2026-05-14', '面板老化亮度不足', '待審核');
UPDATE RetirementRequest SET retStatus='駁回', retApprovedBy=9,
       retRejectReason='亮度仍在可接受範圍，暫不報廢' WHERE retId=4;

-- Retire#5：eId=4（數位相機）→ 駁回
INSERT INTO RetirementRequest (retId, eId, mId, retDate, retReason, retStatus)
VALUES (5, 4, 4, '2026-05-28', '鏡頭模組損壞', '待審核');
UPDATE RetirementRequest SET retStatus='駁回', retApprovedBy=1,
       retRejectReason='維修後可正常使用' WHERE retId=5;

-- Retire#6：eId=17（開發板，歷史設備）→ 核准 → Trigger 搬移至 RetiredEquipment
-- retiredDate=2026-05-30，retApprovedBy=9
INSERT INTO RetirementRequest (retId, eId, mId, retDate, retReason, retStatus)
VALUES (6, 17, 9, '2026-05-29', '開發板維修成本過高且零件停產', '待審核');
UPDATE RetirementRequest SET retStatus='核准', retApprovedBy=9 WHERE retId=6;

-- Retire#7：eId=11（桌上型電腦，歷史設備）→ 核准 → Trigger 搬移至 RetiredEquipment
-- retiredDate=2026-06-03，retApprovedBy=1
INSERT INTO RetirementRequest (retId, eId, mId, retDate, retReason, retStatus)
VALUES (7, 11, 1, '2026-06-02', '主機板故障且已停產', '待審核');
UPDATE RetirementRequest SET retStatus='核准', retApprovedBy=1 WHERE retId=7;

-- Retire#8：eId=9（網路儲存設備）→ 駁回
INSERT INTO RetirementRequest (retId, eId, mId, retDate, retReason, retStatus)
VALUES (8, 9, 2, '2026-06-05', '儲存設備容量不足', '待審核');
UPDATE RetirementRequest SET retStatus='駁回', retApprovedBy=9,
       retRejectReason='設備仍符合教學需求' WHERE retId=8;

-- Retire#9：eId=13（鍵盤，歷史設備）→ 核准 → Trigger 搬移至 RetiredEquipment
-- retiredDate=2026-06-09，retApprovedBy=1
INSERT INTO RetirementRequest (retId, eId, mId, retDate, retReason, retStatus)
VALUES (9, 13, 1, '2026-06-08', '鍵盤按鍵損壞嚴重', '待審核');
UPDATE RetirementRequest SET retStatus='核准', retApprovedBy=1 WHERE retId=9;


-- =============================================
-- (7) BorrowRecord 第二批（目前進行中）
-- =============================================

-- Borrow#7：eId=1（筆記型電腦）→ 逾期（進行中）
INSERT INTO BorrowRecord (bId, mId, eId, bApplyDate, bStartDate, bEndDate, bStatus)
VALUES (7, 3, 1, '2026-05-15', '2026-05-17', '2026-05-21', '申請中');
UPDATE BorrowRecord SET bStatus='核准', bApprovedBy=1, bApprovedDate='2026-05-16' WHERE bId=7;
UPDATE BorrowRecord SET bStatus='逾期' WHERE bId=7;
-- eId=1 維持「借出中」

-- Borrow#9：eId=7（伺服器）→ 申請中（進行中）
INSERT INTO BorrowRecord (bId, mId, eId, bApplyDate, bStartDate, bEndDate, bStatus)
VALUES (9, 7, 7, '2026-05-24', '2026-05-26', '2026-06-02', '申請中');
-- eId=7 維持「借出中」

-- Borrow#10：eId=8（鍵盤）→ 核准（進行中）
INSERT INTO BorrowRecord (bId, mId, eId, bApplyDate, bStartDate, bEndDate, bStatus)
VALUES (10, 6, 8, '2026-05-28', '2026-05-29', '2026-06-05', '申請中');
UPDATE BorrowRecord SET bStatus='核准', bApprovedBy=1, bApprovedDate='2026-05-29' WHERE bId=10;
-- eId=8 維持「借出中」


-- =============================================
-- (8) MaintenanceRecord 第二批（目前進行中）
-- =============================================

-- Maint#5：eId=9（網路儲存設備）→ 處理中（進行中）
INSERT INTO MaintenanceRecord (mRecId, eId, mId, mRecDate, mIssue, mStatus)
VALUES (5, 9, 1, '2026-05-17', 'NAS磁碟警告', '待處理');
UPDATE MaintenanceRecord SET mStatus='處理中', mStaff='陳工程' WHERE mRecId=5;
-- eId=9 維持「維修中」


-- =============================================
-- (9) RetirementRequest 第二批（目前進行中）
-- =============================================

-- Retire#10：eId=2（投影機）→ 待審核（進行中）
INSERT INTO RetirementRequest (retId, eId, mId, retDate, retReason, retStatus)
VALUES (10, 2, 4, '2026-06-10', '投影亮度下降', '待審核');
-- eId=2 維持「報廢中」


-- =============================================
-- 最終狀態驗證
-- =============================================
SELECT '=== Equipment 最終狀態（10台現役） ===' AS '';
SELECT e.eId, CONCAT(c.cCode, '-', e.eSN) AS 完整財編, e.eName, e.eStatus
FROM Equipment e JOIN Category c ON e.cId = c.cId ORDER BY e.eId;

SELECT '=== RetiredEquipment（應有4筆：eId=11,13,15,17） ===' AS '';
SELECT re.eId, CONCAT(c.cCode, '-', re.eSN) AS 完整財編, re.eName,
       re.retReason, re.retApprovedBy, re.retiredDate
FROM RetiredEquipment re JOIN Category c ON re.cId = c.cId ORDER BY re.retiredDate;

SELECT '=== BorrowRecord ===' AS '';
SELECT bId, eId, ePropertyNo, bStatus FROM BorrowRecord ORDER BY bId;

SELECT '=== MaintenanceRecord ===' AS '';
SELECT mRecId, eId, ePropertyNo, mStatus FROM MaintenanceRecord ORDER BY mRecId;

SELECT '=== RetirementRequest ===' AS '';
SELECT retId, eId, ePropertyNo, retStatus FROM RetirementRequest ORDER BY retId;

SELECT '=== 狀態總覽 ===' AS '';
SELECT eStatus AS 狀態, COUNT(*) AS 數量 FROM Equipment GROUP BY eStatus;
