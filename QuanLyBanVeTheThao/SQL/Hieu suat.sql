-- QUẢN LÝ HIỆU SUẤT
USE QLVETHETHAO;
GO
-- View giám sát thông tin indexes
IF OBJECT_ID('QuanLyVe.vw_ThongTinIndex', 'V') IS NOT NULL
    DROP VIEW QuanLyVe.vw_ThongTinIndex;
GO
CREATE VIEW QuanLyVe.vw_ThongTinIndex AS
SELECT 
    t.name AS TableName,
    i.name AS IndexName,
    i.type_desc AS IndexType,
    i.is_unique AS IsUnique,
    i.is_primary_key AS IsPrimaryKey
FROM sys.indexes i
INNER JOIN sys.tables t ON i.object_id = t.object_id
WHERE i.name IS NOT NULL AND t.name NOT LIKE 'sys%';
GO
-- View thống kê hiệu suất tables
IF OBJECT_ID('QuanLyVe.vw_ThongKeTable', 'V') IS NOT NULL
    DROP VIEW QuanLyVe.vw_ThongKeTable;
GO
CREATE VIEW QuanLyVe.vw_ThongKeTable AS
SELECT 
    'KHACHHANG' AS TableName, 
    COUNT(*) AS RecordCount,
    (SELECT COUNT(*) FROM KHACHHANG WHERE DiemTichLuy >= 300) AS KhachHangVang
FROM KHACHHANG
UNION ALL
SELECT 'SUKIEN', COUNT(*), (SELECT COUNT(*) FROM SUKIEN WHERE ThoiGian > GETDATE()) FROM SUKIEN
UNION ALL
SELECT 'DONVE', COUNT(*), (SELECT COUNT(*) FROM DONVE WHERE TrangThai = N'Hoàn thành') FROM DONVE
UNION ALL
SELECT 'CHITIETVE', COUNT(*), (SELECT COUNT(*) FROM CHITIETVE WHERE SoLuong > 1) FROM CHITIETVE
UNION ALL
SELECT 'CHONGOI', COUNT(*), (SELECT COUNT(*) FROM CHONGOI WHERE TrangThai = N'Trống') FROM CHONGOI;
GO
-- Stored procedure phân tích hiệu suất
IF OBJECT_ID('QuanLyVe.sp_PhanTichHieuSuat', 'P') IS NOT NULL
    DROP PROCEDURE QuanLyVe.sp_PhanTichHieuSuat;
GO
CREATE PROCEDURE QuanLyVe.sp_PhanTichHieuSuat
AS
BEGIN
    -- Thống kê số lượng bản ghi
    SELECT * FROM QuanLyVe.vw_ThongKeTable;
    -- Thông tin indexes
    SELECT * FROM QuanLyVe.vw_ThongTinIndex;   
    -- Thống kê hiệu suất queries
    SELECT 
        TenSuKien,
        TheLoai,
        ThoiGian,
        SoLuongVe,
        dbo.fn_SoGheConTrong(MaSuKien) AS GheConTrong
    FROM SUKIEN 
    WHERE ThoiGian > GETDATE()
    ORDER BY ThoiGian;    
    -- Thống kê khách hàng VIP
    SELECT 
        HoTen,
        SoDienThoai,
        DiemTichLuy,
        dbo.fn_HangKhachHang(MaKhachHang) AS Hang,
        dbo.fn_TongChiTieu_KhachHang(MaKhachHang) AS TongChiTieu
    FROM KHACHHANG
    WHERE DiemTichLuy >= 150
    ORDER BY DiemTichLuy DESC;
END;
GO
-- Stored procedure tối ưu database
IF OBJECT_ID('QuanLyVe.sp_ToiUuDatabase', 'P') IS NOT NULL
    DROP PROCEDURE QuanLyVe.sp_ToiUuDatabase;
GO
CREATE PROCEDURE QuanLyVe.sp_ToiUuDatabase
AS
BEGIN
    -- Update statistics cho tất cả tables
    EXEC sp_updatestats;  
    -- Rebuild indexes có mức độ phân mảnh cao
    DECLARE @TableName NVARCHAR(255);
    DECLARE @IndexName NVARCHAR(255);
    DECLARE @Fragmentation FLOAT;    
    DECLARE IndexCursor CURSOR FOR
    SELECT 
        OBJECT_NAME(ips.object_id) AS TableName,
        si.name AS IndexName,
        ips.avg_fragmentation_in_percent
    FROM sys.dm_db_index_physical_stats(DB_ID(), NULL, NULL, NULL, 'LIMITED') ips
    INNER JOIN sys.indexes si ON ips.object_id = si.object_id AND ips.index_id = si.index_id
    WHERE ips.avg_fragmentation_in_percent > 30
        AND si.name IS NOT NULL;    
    OPEN IndexCursor;
    FETCH NEXT FROM IndexCursor INTO @TableName, @IndexName, @Fragmentation;   
    WHILE @@FETCH_STATUS = 0
    BEGIN
        EXEC('ALTER INDEX [' + @IndexName + '] ON [' + @TableName + '] REBUILD');      
        FETCH NEXT FROM IndexCursor INTO @TableName, @IndexName, @Fragmentation;
    END;  
    CLOSE IndexCursor;
    DEALLOCATE IndexCursor;
END;
GO
-- Phân quyền quản lý hiệu suất cho quản trị viên
GRANT EXECUTE ON QuanLyVe.sp_PhanTichHieuSuat TO db_quantri;
GRANT EXECUTE ON QuanLyVe.sp_ToiUuDatabase TO db_quantri;
GRANT SELECT ON QuanLyVe.vw_ThongTinIndex TO db_quantri;
GRANT SELECT ON QuanLyVe.vw_ThongKeTable TO db_quantri;
GO