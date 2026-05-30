-- =============================================
-- 資工系設備管理與維護系統
-- Department Equipment Management & Maintenance System
-- Group 4 | National Formosa University
-- 01_create_tables.sql - 建置資料表
-- =============================================

-- 使用資料庫
USE nfu;

-- 清除舊資料表（注意順序：先刪有 FK 的子表，再刪父表）
SET FOREIGN_KEY_CHECKS = 0;
DROP TABLE IF EXISTS RetirementRequest;
DROP TABLE IF EXISTS MaintenanceRecord;
DROP TABLE IF EXISTS BorrowRecord;
DROP TABLE IF EXISTS Equipment;
DROP TABLE IF EXISTS Category;
DROP TABLE IF EXISTS Member;
SET FOREIGN_KEY_CHECKS = 1;

-- =============================================
-- (1) Member 使用者資料表
-- 系統核心使用者實體，依 mRole 區分管理員、教師、學生
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

    CONSTRAINT chk_mEmail   CHECK (mEmail  LIKE '%@%'),
    CONSTRAINT chk_mRole    CHECK (mRole   IN ('管理員', '教師', '學生')),
    CONSTRAINT chk_mPhone   CHECK (mPhone  IS NULL OR (mPhone REGEXP '^09[0-9]{8}$'))
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;


-- =============================================
-- (2) Category 設備類別資料表
-- 建立前先於 Equipment 使用，故需先建立
-- =============================================
CREATE TABLE Category (
    cId      INT          NOT NULL AUTO_INCREMENT,
    cName    VARCHAR(16)  NOT NULL,
    cOutline VARCHAR(64)  NULL,

    PRIMARY KEY (cId)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;


-- =============================================
-- (3) Equipment 設備資料表
-- 系統最核心的資產實體，ePropertyNo 為財產管理依據
-- =============================================
CREATE TABLE Equipment (
    eId           INT           NOT NULL AUTO_INCREMENT,
    ePropertyNo   VARCHAR(20)   NOT NULL,
    eName         VARCHAR(40)   NOT NULL,
    cId           INT           NOT NULL,
    eStatus       VARCHAR(6)    NOT NULL DEFAULT '可用',
    eLocation     VARCHAR(64)   NOT NULL,
    ePurchaseDate DATE          NOT NULL,
    eWarrantyDate DATE          NULL,
    eNote         VARCHAR(256)  NULL,

    PRIMARY KEY (eId),
    UNIQUE KEY uq_ePropertyNo (ePropertyNo),

    CONSTRAINT fk_equipment_category
        FOREIGN KEY (cId) REFERENCES Category(cId)
        ON UPDATE RESTRICT ON DELETE RESTRICT,

    CONSTRAINT chk_ePropertyNo
        CHECK (ePropertyNo LIKE 'EQ%'),
    CONSTRAINT chk_eStatus
        CHECK (eStatus IN ('可用', '借出中', '維修中', '報廢')),
    -- chk_ePurchaseDate: MariaDB 不支援 CHECK 中使用動態函數，請在應用層控制
    CONSTRAINT chk_eWarrantyDate
        CHECK (eWarrantyDate IS NULL OR eWarrantyDate >= ePurchaseDate)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;


-- =============================================
-- (4) BorrowRecord 借用紀錄資料表
-- Member 與 Equipment 之間多對多借用關係的橋接表
-- =============================================
CREATE TABLE BorrowRecord (
    bId           INT         NOT NULL AUTO_INCREMENT,
    mId           INT         NOT NULL,
    eId           INT         NOT NULL,
    bApplyDate    DATE        NOT NULL,
    bApprovedBy   INT         NULL,       -- 申請中時尚未審核，允許 NULL
    bApprovedDate DATE        NULL,
    bStartDate    DATE        NOT NULL,
    bEndDate      DATE        NOT NULL,
    bReturnDate   DATE        NULL,
    bStatus       VARCHAR(6)  NOT NULL DEFAULT '申請中',

    PRIMARY KEY (bId),

    CONSTRAINT fk_borrow_member
        FOREIGN KEY (mId)         REFERENCES Member(mId)
        ON UPDATE RESTRICT ON DELETE RESTRICT,
    CONSTRAINT fk_borrow_equipment
        FOREIGN KEY (eId)         REFERENCES Equipment(eId)
        ON UPDATE RESTRICT ON DELETE RESTRICT,
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
-- Member 與 Equipment 之間維護關係的橋接表
-- =============================================
CREATE TABLE MaintenanceRecord (
    mRecId   INT          NOT NULL AUTO_INCREMENT,
    eId      INT          NOT NULL,
    mId      INT          NOT NULL,
    mRecDate DATE         NOT NULL,
    mIssue   VARCHAR(256) NOT NULL,
    mResult  VARCHAR(256) NULL,
    mStaff   VARCHAR(32)  NULL,
    mStatus  VARCHAR(6)   NOT NULL DEFAULT '待處理',

    PRIMARY KEY (mRecId),

    CONSTRAINT fk_maintenance_equipment
        FOREIGN KEY (eId) REFERENCES Equipment(eId)
        ON UPDATE RESTRICT ON DELETE RESTRICT,
    CONSTRAINT fk_maintenance_member
        FOREIGN KEY (mId) REFERENCES Member(mId)
        ON UPDATE RESTRICT ON DELETE RESTRICT,

    CONSTRAINT chk_mStatus
        CHECK (mStatus IN ('待處理', '處理中', '已完成'))
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;


-- =============================================
-- (6) RetirementRequest 報廢申請資料表
-- Member 與 Equipment 之間報廢申請關係的橋接表
-- 申請通過後需連動更新 Equipment.eStatus 為「報廢」
-- =============================================
CREATE TABLE RetirementRequest (
    retId     INT          NOT NULL AUTO_INCREMENT,
    eId       INT          NOT NULL,
    mId       INT          NOT NULL,
    retDate   DATE         NOT NULL,
    retReason VARCHAR(256) NOT NULL,
    retStatus VARCHAR(6)   NOT NULL DEFAULT '待審核',

    PRIMARY KEY (retId),

    CONSTRAINT fk_retire_equipment
        FOREIGN KEY (eId) REFERENCES Equipment(eId)
        ON UPDATE RESTRICT ON DELETE RESTRICT,
    CONSTRAINT fk_retire_member
        FOREIGN KEY (mId) REFERENCES Member(mId)
        ON UPDATE RESTRICT ON DELETE RESTRICT,

    CONSTRAINT chk_retStatus
        CHECK (retStatus IN ('待審核', '核准', '駁回'))
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;


-- =============================================
-- 確認所有資料表建立完成
-- =============================================
SHOW TABLES;
