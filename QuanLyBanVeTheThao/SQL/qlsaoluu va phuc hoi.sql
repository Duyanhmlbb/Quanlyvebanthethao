-- QUẢN LÝ SAO LƯU VÀ PHỤC HỒI
USE QLVETHETHAO;
GO
--Tạo bảng lịch sử backup
IF OBJECT_ID('QuanLyVe.LICHSUBACKUP', 'U') IS NOT NULL
    DROP TABLE QuanLyVe.LICHSUBACKUP;
GO
CREATE TABLE QuanLyVe.LICHSUBACKUP (
    MaBackup INT IDENTITY(1,1) PRIMARY KEY,
    TenBackup NVARCHAR(100) NOT NULL,
    LoaiBackup NVARCHAR(20) NOT NULL,
    DuongDan NVARCHAR(500) NOT NULL,
    NgayBackup DATETIME DEFAULT GETDATE(),
    KichThuocMB DECIMAL(10,2),
    TrangThai NVARCHAR(20) DEFAULT N'Thành công',
    CONSTRAINT CHK_LSB_LOAI CHECK (LoaiBackup IN (N'Full', N'Differential'))
);
GO
-- Stored procedure cho backup full database
IF OBJECT_ID('QuanLyVe.sp_BackupFullDatabase', 'P') IS NOT NULL
    DROP PROCEDURE QuanLyVe.sp_BackupFullDatabase;
GO
CREATE PROCEDURE QuanLyVe.sp_BackupFullDatabase
    @BackupPath NVARCHAR(500) = 'C:\Backup\QLVETHETHAO_Full.bak'
AS
BEGIN
    BEGIN TRY
        DECLARE @BackupName NVARCHAR(100) = N'Full Backup of QLVETHETHAO - ' + CONVERT(NVARCHAR(20), GETDATE(), 120);       
        BACKUP DATABASE QLVETHETHAO 
        TO DISK = @BackupPath
        WITH FORMAT, NAME = @BackupName;       
        -- Ghi log vào bảng lịch sử
        INSERT INTO QuanLyVe.LICHSUBACKUP (TenBackup, LoaiBackup, DuongDan, KichThuocMB)
        VALUES (@BackupName, N'Full', @BackupPath, 
               (SELECT backup_size / 1048576.0 FROM msdb.dbo.backupset 
                WHERE database_name = 'QLVETHETHAO' 
                AND backup_start_date = (SELECT MAX(backup_start_date) 
                                       FROM msdb.dbo.backupset 
                                       WHERE database_name = 'QLVETHETHAO')));
    END TRY
    BEGIN CATCH
        -- Ghi log lỗi
        INSERT INTO QuanLyVe.LICHSUBACKUP (TenBackup, LoaiBackup, DuongDan, TrangThai)
        VALUES (@BackupName, N'Full', @BackupPath, N'Thất bại');
        
        DECLARE @ErrorMessage NVARCHAR(4000) = ERROR_MESSAGE();
        RAISERROR(N'Backup thất bại: %s', 16, 1, @ErrorMessage);
    END CATCH
END;
GO
-- Stored procedure cho backup differential
IF OBJECT_ID('QuanLyVe.sp_BackupDifferential', 'P') IS NOT NULL
    DROP PROCEDURE QuanLyVe.sp_BackupDifferential;
GO
CREATE PROCEDURE QuanLyVe.sp_BackupDifferential
    @BackupPath NVARCHAR(500) = 'C:\Backup\QLVETHETHAO_Diff.bak'
AS
BEGIN
    BEGIN TRY
        DECLARE @BackupName NVARCHAR(100) = N'Differential Backup of QLVETHETHAO - ' + CONVERT(NVARCHAR(20), GETDATE(), 120);        
        BACKUP DATABASE QLVETHETHAO 
        TO DISK = @BackupPath
        WITH DIFFERENTIAL, NAME = @BackupName;     
        -- Ghi log vào bảng lịch sử
        INSERT INTO QuanLyVe.LICHSUBACKUP (TenBackup, LoaiBackup, DuongDan, KichThuocMB)
        VALUES (@BackupName, N'Differential', @BackupPath, 
               (SELECT backup_size / 1048576.0 FROM msdb.dbo.backupset 
                WHERE database_name = 'QLVETHETHAO' 
                AND backup_start_date = (SELECT MAX(backup_start_date) 
                                       FROM msdb.dbo.backupset 
                                       WHERE database_name = 'QLVETHETHAO')));
    END TRY
    BEGIN CATCH
        INSERT INTO QuanLyVe.LICHSUBACKUP (TenBackup, LoaiBackup, DuongDan, TrangThai)
        VALUES (@BackupName, N'Differential', @BackupPath, N'Thất bại');
        
        DECLARE @ErrorMessage NVARCHAR(4000) = ERROR_MESSAGE();
        RAISERROR(N'Backup differential thất bại: %s', 16, 1, @ErrorMessage);
    END CATCH
END;
GO
-- Stored procedure cho restore database
IF OBJECT_ID('QuanLyVe.sp_RestoreDatabase', 'P') IS NOT NULL
    DROP PROCEDURE QuanLyVe.sp_RestoreDatabase;
GO
CREATE PROCEDURE QuanLyVe.sp_RestoreDatabase
    @BackupPath NVARCHAR(500) = 'C:\Backup\QLVETHETHAO_Full.bak'
AS
BEGIN
    BEGIN TRY
        -- Đưa database vào single user mode
        ALTER DATABASE QLVETHETHAO SET SINGLE_USER WITH ROLLBACK IMMEDIATE;       
        -- Restore database
        RESTORE DATABASE QLVETHETHAO 
        FROM DISK = @BackupPath
        WITH REPLACE;   
        -- Đưa database trở lại multi user mode
        ALTER DATABASE QLVETHETHAO SET MULTI_USER;
    END TRY
    BEGIN CATCH
        -- Đảm bảo database trở lại multi user mode nếu có lỗi
        ALTER DATABASE QLVETHETHAO SET MULTI_USER;
        
        DECLARE @ErrorMessage NVARCHAR(4000) = ERROR_MESSAGE();
        RAISERROR(N'Restore thất bại: %s', 16, 1, @ErrorMessage);
    END CATCH
END;
GO
-- View xem lịch sử backup
IF OBJECT_ID('QuanLyVe.vw_LichSuBackup', 'V') IS NOT NULL
    DROP VIEW QuanLyVe.vw_LichSuBackup;
GO
CREATE VIEW QuanLyVe.vw_LichSuBackup AS
SELECT TOP 100 PERCENT
    MaBackup,
    TenBackup,
    LoaiBackup,
    DuongDan,
    NgayBackup,
    KichThuocMB,
    TrangThai
FROM QuanLyVe.LICHSUBACKUP
ORDER BY NgayBackup DESC;
GO
-- Phân quyền backup/restore cho quản trị viên
GRANT EXECUTE ON QuanLyVe.sp_BackupFullDatabase TO db_quantri;
GRANT EXECUTE ON QuanLyVe.sp_BackupDifferential TO db_quantri;
GRANT EXECUTE ON QuanLyVe.sp_RestoreDatabase TO db_quantri;
GRANT SELECT ON QuanLyVe.vw_LichSuBackup TO db_quantri;
GO