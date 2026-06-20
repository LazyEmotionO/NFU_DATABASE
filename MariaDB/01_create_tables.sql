-- =============================================
-- 資工系設備管理與維護系統
-- Department Equipment Management & Maintenance System
-- Group 4 
-- =============================================

USE nfu;

SET FOREIGN_KEY_CHECKS = 0;
DROP TABLE IF EXISTS RetiredEquipment;
DROP TABLE IF EXISTS RetirementRequest;
DROP TABLE IF EXISTS MaintenanceRecord;
DROP TABLE IF EXISTS BorrowRecord;
DROP TABLE IF EXISTS Equipment;
DROP TABLE IF EXISTS Category;
DROP TABLE IF EXISTS Member;
SET FOREIGN_KEY_CHECKS = 1;


-- =============================================
-- (1) Member 使用者資料表
-- =============================================
CREATE TABLE Member (
    mId         INT             NOT NULL AUTO_INCREMENT,
    mAccount    VARCHAR(20)     NOT NULL,
    mName       VARCHAR(12)     NOT NULL,
    mEmail      VARCHAR(50)     NOT NULL,
    mPhone      CHAR(10)        NULL,
    mRole       VARCHAR(6)      NOT NULL,
    mCreateDate DATE            NOT NULL DEFAULT CURRENT_DATE,

    PRIMARY KEY (mId),
    UNIQUE KEY uq_mAccount (mAccount),
    UNIQUE KEY uq_mEmail   (mEmail),

    CONSTRAINT chk_mEmail
        CHECK (mEmail REGEXP '^[A-Za-z0-9._%+-]+@nfu\\.edu\\.tw$'),
    CONSTRAINT chk_mRole    CHECK (mRole  IN ('管理員', '教師', '學生')),
    CONSTRAINT chk_mPhone   CHECK (mPhone IS NULL OR mPhone REGEXP '^09[0-9]{8}$')
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;


-- =============================================
-- (2) Category 設備類別資料表
-- cCode：教育部財物分類節碼（格式 3140101-03）
-- 完整財編 = CONCAT(cCode, '-', Equipment.eSN)
-- =============================================
CREATE TABLE Category (
    cId      INT          NOT NULL AUTO_INCREMENT,
    cCode    VARCHAR(12)  NOT NULL,   -- 教育部財物分類節碼，例如 '3140101-03'
    cName    VARCHAR(16)  NOT NULL,
    cOutline VARCHAR(64)  NULL,

    PRIMARY KEY (cId),
    UNIQUE KEY uq_cCode (cCode),

    CONSTRAINT chk_cCode
        CHECK (cCode REGEXP '^[0-9]{7}-[0-9]{2}$')
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;


-- =============================================
-- (3) Equipment 設備資料表
-- eSN：設備序號（後段），完整財編需搭配 Category.cCode 組合
-- 完整財編 = CONCAT(c.cCode, '-', e.eSN)
-- =============================================
CREATE TABLE Equipment (
    eId           INT           NOT NULL AUTO_INCREMENT,
    eSN           VARCHAR(10)   NOT NULL,  -- 序號，例如 '0034860'
    eName         VARCHAR(40)   NOT NULL,
    eSpec         VARCHAR(64)   NULL,      -- 規格型號
    cId           INT           NOT NULL,
    eStatus       VARCHAR(6)    NOT NULL DEFAULT '可用',
    eLocation     VARCHAR(64)   NOT NULL,
    ePurchaseDate DATE          NOT NULL,
    eWarrantyDate DATE          NULL,
    eNote         VARCHAR(256)  NULL,

    PRIMARY KEY (eId),
    UNIQUE KEY uq_eSN_cId (eSN, cId),    -- 同分類下序號唯一

    CONSTRAINT fk_equipment_category
        FOREIGN KEY (cId) REFERENCES Category(cId)
        ON UPDATE RESTRICT ON DELETE RESTRICT,

    CONSTRAINT chk_eStatus
        CHECK (eStatus IN ('可用', '借出中', '維修中', '報廢中')),
    CONSTRAINT chk_eWarrantyDate
        CHECK (eWarrantyDate IS NULL OR eWarrantyDate >= ePurchaseDate)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;


-- =============================================
-- (4) BorrowRecord 借用紀錄資料表
-- ePropertyNo：完整財編快照（由 Trigger 自動組合填入）
-- =============================================
CREATE TABLE BorrowRecord (
    bId           INT          NOT NULL AUTO_INCREMENT,
    mId           INT          NOT NULL,
    eId           INT          NULL,
    ePropertyNo   VARCHAR(24)  NULL,   -- 完整財編快照，格式 'cCode-eSN'
    bApplyDate    DATE         NOT NULL,
    bApprovedBy   INT          NULL,
    bApprovedDate DATE         NULL,
    bStartDate    DATE         NOT NULL,
    bEndDate      DATE         NOT NULL,
    bReturnDate   DATE         NULL,
    bStatus       VARCHAR(6)   NOT NULL DEFAULT '申請中',
    bRejectReason VARCHAR(256) NULL,

    PRIMARY KEY (bId),

    CONSTRAINT fk_borrow_member
        FOREIGN KEY (mId)         REFERENCES Member(mId)
        ON UPDATE RESTRICT ON DELETE RESTRICT,
    CONSTRAINT fk_borrow_equipment
        FOREIGN KEY (eId)         REFERENCES Equipment(eId)
        ON UPDATE RESTRICT ON DELETE SET NULL,
    CONSTRAINT fk_borrow_approver
        FOREIGN KEY (bApprovedBy) REFERENCES Member(mId)
        ON UPDATE RESTRICT ON DELETE RESTRICT,

    CONSTRAINT chk_bEndDate
        CHECK (bEndDate >= bStartDate),
    CONSTRAINT chk_bReturnDate
        CHECK (bReturnDate IS NULL OR bReturnDate >= bStartDate),
    CONSTRAINT chk_bStatus
        CHECK (bStatus IN ('申請中', '核准', '已歸還', '逾期', '拒絕'))
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;


-- =============================================
-- (5) MaintenanceRecord 維護紀錄資料表
-- ePropertyNo：完整財編快照（由 Trigger 自動組合填入）
-- =============================================
CREATE TABLE MaintenanceRecord (
    mRecId        INT          NOT NULL AUTO_INCREMENT,
    eId           INT          NULL,
    ePropertyNo   VARCHAR(24)  NULL,   -- 完整財編快照
    mId           INT          NOT NULL,
    mRecDate      DATE         NOT NULL,
    mIssue        VARCHAR(256) NOT NULL,
    mResult       VARCHAR(256) NULL,
    mStaff        VARCHAR(32)  NULL,
    mStatus       VARCHAR(6)   NOT NULL DEFAULT '待處理',
    mRejectReason VARCHAR(256) NULL,

    PRIMARY KEY (mRecId),

    CONSTRAINT fk_maintenance_equipment
        FOREIGN KEY (eId) REFERENCES Equipment(eId)
        ON UPDATE RESTRICT ON DELETE SET NULL,
    CONSTRAINT fk_maintenance_member
        FOREIGN KEY (mId) REFERENCES Member(mId)
        ON UPDATE RESTRICT ON DELETE RESTRICT,

    CONSTRAINT chk_mStatus
        CHECK (mStatus IN ('待處理', '處理中', '已完成', '拒絕'))
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;


-- =============================================
-- (6) RetirementRequest 報廢申請資料表
-- ePropertyNo：完整財編快照（由 Trigger 自動組合填入）
-- =============================================
CREATE TABLE RetirementRequest (
    retId           INT          NOT NULL AUTO_INCREMENT,
    eId             INT          NULL,
    ePropertyNo     VARCHAR(24)  NULL,   -- 完整財編快照
    mId             INT          NOT NULL,
    retDate         DATE         NOT NULL,
    retReason       VARCHAR(256) NOT NULL,
    retStatus       VARCHAR(6)   NOT NULL DEFAULT '待審核',
    retApprovedBy   INT          NULL,
    retRejectReason VARCHAR(256) NULL,

    PRIMARY KEY (retId),

    CONSTRAINT fk_retire_equipment
        FOREIGN KEY (eId) REFERENCES Equipment(eId)
        ON UPDATE RESTRICT ON DELETE SET NULL,
    CONSTRAINT fk_retire_member
        FOREIGN KEY (mId) REFERENCES Member(mId)
        ON UPDATE RESTRICT ON DELETE RESTRICT,
    CONSTRAINT fk_retire_approver
        FOREIGN KEY (retApprovedBy) REFERENCES Member(mId)
        ON UPDATE RESTRICT ON DELETE RESTRICT,

    CONSTRAINT chk_retStatus
        CHECK (retStatus IN ('待審核', '核准', '駁回'))
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;


-- =============================================
-- (7) RetiredEquipment 已報廢設備資料表
-- eSN：沿用原 Equipment.eSN（序號後段）
-- 完整財編 = CONCAT(c.cCode, '-', re.eSN)
-- =============================================
CREATE TABLE RetiredEquipment (
    eId           INT           NOT NULL,
    eSN           VARCHAR(10)   NOT NULL,  -- 序號後段
    eName         VARCHAR(40)   NOT NULL,
    eSpec         VARCHAR(64)   NULL,
    cId           INT           NOT NULL,
    eLocation     VARCHAR(64)   NOT NULL,
    ePurchaseDate DATE          NOT NULL,
    eWarrantyDate DATE          NULL,
    eNote         VARCHAR(256)  NULL,

    retId         INT          NOT NULL,
    retReason     VARCHAR(256) NOT NULL,
    retApprovedBy INT          NOT NULL,
    retiredDate   DATE         NOT NULL DEFAULT CURRENT_DATE,

    PRIMARY KEY (eId),

    CONSTRAINT fk_retired_category
        FOREIGN KEY (cId) REFERENCES Category(cId)
        ON UPDATE RESTRICT ON DELETE RESTRICT,
    CONSTRAINT fk_retired_request
        FOREIGN KEY (retId) REFERENCES RetirementRequest(retId)
        ON UPDATE RESTRICT ON DELETE RESTRICT,
    CONSTRAINT fk_retired_approver
        FOREIGN KEY (retApprovedBy) REFERENCES Member(mId)
        ON UPDATE RESTRICT ON DELETE RESTRICT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;


-- =============================================
-- Trigger：借用申請前檢查 + 自動帶入完整財編快照
-- =============================================
DROP TRIGGER IF EXISTS trg_borrow_before_insert;
DELIMITER $$
CREATE TRIGGER trg_borrow_before_insert
BEFORE INSERT ON BorrowRecord
FOR EACH ROW
BEGIN
    DECLARE cur_status VARCHAR(6);
    DECLARE cur_propno VARCHAR(24);

    SELECT e.eStatus, CONCAT(c.cCode, '-', e.eSN)
      INTO cur_status, cur_propno
      FROM Equipment e
      JOIN Category c ON e.cId = c.cId
     WHERE e.eId = NEW.eId;

    IF cur_status IS NULL THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = '找不到對應的設備，無法提出借用申請';
    ELSEIF cur_status <> '可用' THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = '僅「可用」狀態的設備可提出借用申請';
    END IF;

    IF NEW.ePropertyNo IS NULL THEN
        SET NEW.ePropertyNo = cur_propno;
    END IF;
END$$
DELIMITER ;


DROP TRIGGER IF EXISTS trg_borrow_after_insert;
DELIMITER $$
CREATE TRIGGER trg_borrow_after_insert
AFTER INSERT ON BorrowRecord
FOR EACH ROW
BEGIN
    UPDATE Equipment SET eStatus = '借出中' WHERE eId = NEW.eId;
END$$
DELIMITER ;


DROP TRIGGER IF EXISTS trg_borrow_result;
DELIMITER $$
CREATE TRIGGER trg_borrow_result
AFTER UPDATE ON BorrowRecord
FOR EACH ROW
BEGIN
    IF NEW.eId IS NOT NULL THEN
        IF NEW.bStatus = '拒絕' AND OLD.bStatus <> '拒絕' THEN
            UPDATE Equipment SET eStatus = '可用' WHERE eId = NEW.eId;
        ELSEIF NEW.bStatus = '已歸還' AND OLD.bStatus <> '已歸還' THEN
            UPDATE Equipment SET eStatus = '可用' WHERE eId = NEW.eId;
        END IF;
    END IF;
END$$
DELIMITER ;


-- =============================================
-- Trigger：維護申報前檢查 + 自動帶入完整財編快照
-- =============================================
DROP TRIGGER IF EXISTS trg_maintenance_before_insert;
DELIMITER $$
CREATE TRIGGER trg_maintenance_before_insert
BEFORE INSERT ON MaintenanceRecord
FOR EACH ROW
BEGIN
    DECLARE cur_status VARCHAR(6);
    DECLARE cur_propno VARCHAR(24);

    SELECT e.eStatus, CONCAT(c.cCode, '-', e.eSN)
      INTO cur_status, cur_propno
      FROM Equipment e
      JOIN Category c ON e.cId = c.cId
     WHERE e.eId = NEW.eId;

    IF cur_status IS NULL THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = '找不到對應的設備，無法提出維護申報';
    ELSEIF cur_status <> '可用' THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = '僅「可用」狀態的設備可提出維護申報';
    END IF;

    IF NEW.ePropertyNo IS NULL THEN
        SET NEW.ePropertyNo = cur_propno;
    END IF;
END$$
DELIMITER ;


DROP TRIGGER IF EXISTS trg_maintenance_after_insert;
DELIMITER $$
CREATE TRIGGER trg_maintenance_after_insert
AFTER INSERT ON MaintenanceRecord
FOR EACH ROW
BEGIN
    UPDATE Equipment SET eStatus = '維修中' WHERE eId = NEW.eId;
END$$
DELIMITER ;


DROP TRIGGER IF EXISTS trg_maintenance_result;
DELIMITER $$
CREATE TRIGGER trg_maintenance_result
AFTER UPDATE ON MaintenanceRecord
FOR EACH ROW
BEGIN
    IF NEW.eId IS NOT NULL THEN
        IF NEW.mStatus = '拒絕' AND OLD.mStatus <> '拒絕' THEN
            UPDATE Equipment SET eStatus = '可用' WHERE eId = NEW.eId;
        ELSEIF NEW.mStatus = '已完成' AND OLD.mStatus <> '已完成' THEN
            UPDATE Equipment SET eStatus = '可用' WHERE eId = NEW.eId;
        END IF;
    END IF;
END$$
DELIMITER ;


-- =============================================
-- Trigger：報廢申請前檢查 + 自動帶入完整財編快照
-- =============================================
DROP TRIGGER IF EXISTS trg_retirement_before_insert;
DELIMITER $$
CREATE TRIGGER trg_retirement_before_insert
BEFORE INSERT ON RetirementRequest
FOR EACH ROW
BEGIN
    DECLARE cur_status VARCHAR(6);
    DECLARE cur_propno VARCHAR(24);

    SELECT e.eStatus, CONCAT(c.cCode, '-', e.eSN)
      INTO cur_status, cur_propno
      FROM Equipment e
      JOIN Category c ON e.cId = c.cId
     WHERE e.eId = NEW.eId;

    IF cur_status IS NULL THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = '找不到對應的設備，無法提出報廢申請';
    ELSEIF cur_status <> '可用' THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = '僅「可用」狀態的設備可提出報廢申請';
    END IF;

    IF NEW.ePropertyNo IS NULL THEN
        SET NEW.ePropertyNo = cur_propno;
    END IF;
END$$
DELIMITER ;


DROP TRIGGER IF EXISTS trg_retirement_after_insert;
DELIMITER $$
CREATE TRIGGER trg_retirement_after_insert
AFTER INSERT ON RetirementRequest
FOR EACH ROW
BEGIN
    UPDATE Equipment SET eStatus = '報廢中' WHERE eId = NEW.eId;
END$$
DELIMITER ;


DROP TRIGGER IF EXISTS trg_retirement_rejected;
DELIMITER $$
CREATE TRIGGER trg_retirement_rejected
AFTER UPDATE ON RetirementRequest
FOR EACH ROW
BEGIN
    IF NEW.retStatus = '駁回' AND OLD.retStatus <> '駁回' AND NEW.eId IS NOT NULL THEN
        UPDATE Equipment SET eStatus = '可用' WHERE eId = NEW.eId;
    END IF;
END$$
DELIMITER ;


-- =============================================
-- Trigger：報廢核准後自動搬移至 RetiredEquipment
-- =============================================
DROP TRIGGER IF EXISTS trg_retirement_approved;
DELIMITER $$
CREATE TRIGGER trg_retirement_approved
AFTER UPDATE ON RetirementRequest
FOR EACH ROW
BEGIN
    IF NEW.retStatus = '核准' AND OLD.retStatus <> '核准' THEN

        INSERT INTO RetiredEquipment
            (eId, eSN, eName, eSpec, cId, eLocation,
             ePurchaseDate, eWarrantyDate, eNote,
             retId, retReason, retApprovedBy, retiredDate)
        SELECT
            e.eId, e.eSN, e.eName, e.eSpec, e.cId, e.eLocation,
            e.ePurchaseDate, e.eWarrantyDate, e.eNote,
            NEW.retId, NEW.retReason, NEW.retApprovedBy, CURRENT_DATE
        FROM Equipment e
        WHERE e.eId = NEW.eId;

        DELETE FROM Equipment WHERE eId = NEW.eId;

    END IF;
END$$
DELIMITER ;


-- =============================================
-- EVENT：每日自動檢查逾期借用
-- =============================================
SET GLOBAL event_scheduler = ON;

DROP EVENT IF EXISTS evt_check_overdue_borrow;

CREATE EVENT evt_check_overdue_borrow
ON SCHEDULE EVERY 1 DAY
STARTS CURRENT_TIMESTAMP
DO
    UPDATE BorrowRecord
       SET bStatus = '逾期'
     WHERE bStatus = '核准'
       AND bEndDate < CURRENT_DATE;


-- =============================================
-- 確認建立完成
-- =============================================
SHOW TABLES;
SHOW TRIGGERS;
SHOW EVENTS;
