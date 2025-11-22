-- TRIGGERS
USE QLVETHETHAO;
GO
--  Kiểm tra số lượng vé khi thêm chi tiết vé
IF OBJECT_ID('trg_AfterInsert_CHITIETVE', 'TR') IS NOT NULL
    DROP TRIGGER trg_AfterInsert_CHITIETVE;
GO
CREATE TRIGGER trg_AfterInsert_CHITIETVE
ON CHITIETVE
AFTER INSERT
AS
BEGIN
    SET NOCOUNT ON;    
    -- Kiểm tra số lượng vé không vượt quá tổng số vé
    IF EXISTS (
        SELECT 1 
        FROM inserted i
        JOIN SUKIEN s ON i.MaSuKien = s.MaSuKien
        JOIN (SELECT MaSuKien, SUM(SoLuong) AS TongSoLuong FROM CHITIETVE GROUP BY MaSuKien) ct 
        ON s.MaSuKien = ct.MaSuKien
        WHERE ct.TongSoLuong > s.SoLuongVe
    )
    BEGIN
        RAISERROR(N'Số lượng vé vượt quá giới hạn!', 16, 1);
        ROLLBACK TRANSACTION;
        RETURN;
    END;
END;
GO
-- trg_AfterDelete_CHITIETVE: Hoàn trả số lượng vé khi xóa
IF OBJECT_ID('trg_AfterDelete_CHITIETVE', 'TR') IS NOT NULL
    DROP TRIGGER trg_AfterDelete_CHITIETVE;
GO
CREATE TRIGGER trg_AfterDelete_CHITIETVE
ON CHITIETVE
AFTER DELETE
AS
BEGIN
    SET NOCOUNT ON;
    -- Cập nhật trạng thái chỗ ngồi về trống
    UPDATE CHONGOI 
    SET TrangThai = N'Trống'
    WHERE MaChoNgoi IN (SELECT MaChoNgoi FROM deleted WHERE MaChoNgoi IS NOT NULL);
END;
GO
-- Kiểm tra chỗ ngồi không trùng
IF OBJECT_ID('trg_CheckGheTrung', 'TR') IS NOT NULL
    DROP TRIGGER trg_CheckGheTrung;
GO
CREATE TRIGGER trg_CheckGheTrung
ON CHITIETVE
AFTER INSERT, UPDATE
AS
BEGIN
    IF EXISTS (
        SELECT MaSuKien, MaChoNgoi 
        FROM CHITIETVE 
        WHERE MaChoNgoi IS NOT NULL
        GROUP BY MaSuKien, MaChoNgoi 
        HAVING COUNT(*) > 1
    )
    BEGIN
        RAISERROR(N'Chỗ ngồi đã được đặt!', 16, 1);
        ROLLBACK TRANSACTION;
    END
END;
GO