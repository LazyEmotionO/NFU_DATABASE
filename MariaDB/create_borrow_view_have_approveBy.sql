use nfu;
CREATE VIEW v_borrowed_equipment_haveBorrowApproveName AS
SELECT
    b.bId,
    e.ePropertyNo   AS 財產編號,
    e.eName         AS 設備名稱,
    mb.mName        AS 借用人,
    mb.mRole        AS 借用人角色,
    b.bStartDate    AS 借用開始日,
    b.bEndDate      AS 應還日期,
    b.bStatus       AS 借用狀態,
    b.bApprovedBy   AS 確認人ID,
    mb2.mName       AS 確認人名字
FROM BorrowRecord b
JOIN Equipment e  ON b.eId = e.eId
JOIN Member mb    ON b.mId = mb.mId
JOIN Member mb2   ON b.bApprovedBy = mb2.mId
WHERE b.bStatus IN ('核准', '逾期');