-- QUẢN LÝ NGƯỜI DÙNG VÀ QUYỀN TRUY CẬP
USE QLVETHETHAO;
GO
-- Tạo các role
IF NOT EXISTS (SELECT * FROM sys.database_principals WHERE name = 'db_quantri')
    CREATE ROLE db_quantri;
IF NOT EXISTS (SELECT * FROM sys.database_principals WHERE name = 'db_nhanvien')  
    CREATE ROLE db_nhanvien;
IF NOT EXISTS (SELECT * FROM sys.database_principals WHERE name = 'db_khachhang')
    CREATE ROLE db_khachhang;
GO
-- Phân quyền cho quản trị viên
GRANT SELECT, INSERT, UPDATE, DELETE ON PHONGVE TO db_quantri;
GRANT SELECT, INSERT, UPDATE, DELETE ON KHACHHANG TO db_quantri;
GRANT SELECT, INSERT, UPDATE, DELETE ON NHATOCHUC TO db_quantri;
GRANT SELECT, INSERT, UPDATE, DELETE ON SUKIEN TO db_quantri;
GRANT SELECT, INSERT, UPDATE, DELETE ON DONVE TO db_quantri;
GRANT SELECT, INSERT, UPDATE, DELETE ON CHONGOI TO db_quantri;
GRANT SELECT, INSERT, UPDATE, DELETE ON CHITIETVE TO db_quantri;
GRANT SELECT, INSERT, UPDATE, DELETE ON BAOCAODOANHTHU TO db_quantri;
GRANT SELECT, INSERT, UPDATE, DELETE ON BAOCAOVE TO db_quantri;
-- Phân quyền views cho quản trị viên
GRANT SELECT ON vw_DoanhThuTheoSuKien TO db_quantri;
GRANT SELECT ON vw_ThongTinDatVe TO db_quantri;
GRANT SELECT ON vw_GheConTrongTheoSuKien TO db_quantri;
GO
-- Phân quyền cho nhân viên
GRANT SELECT, INSERT, UPDATE ON DONVE TO db_nhanvien;
GRANT SELECT, INSERT, UPDATE ON CHITIETVE TO db_nhanvien;
GRANT SELECT ON KHACHHANG TO db_nhanvien;
GRANT SELECT ON SUKIEN TO db_nhanvien;
GRANT SELECT ON CHONGOI TO db_nhanvien;
GRANT SELECT ON PHONGVE TO db_nhanvien;
GRANT EXECUTE ON sp_TaoDonVe TO db_nhanvien;
GRANT EXECUTE ON sp_BaoCaoDoanhThuTheoKhoangThoiGian TO db_nhanvien;
-- Phân quyền views cho nhân viên
GRANT SELECT ON vw_ThongTinDatVe TO db_nhanvien;
GRANT SELECT ON vw_GheConTrongTheoSuKien TO db_nhanvien;
GO
-- Phân quyền cho khách hàng
GRANT SELECT ON SUKIEN TO db_khachhang;
GRANT SELECT ON CHONGOI TO db_khachhang;
-- Phân quyền views cho khách hàng
GRANT SELECT ON vw_GheConTrongTheoSuKien TO db_khachhang;
GO
-- Tạo user mẫu
IF NOT EXISTS (SELECT * FROM sys.database_principals WHERE name = 'user_quantri')
    CREATE USER user_quantri WITHOUT LOGIN;

IF NOT EXISTS (SELECT * FROM sys.database_principals WHERE name = 'user_nhanvien')  
    CREATE USER user_nhanvien WITHOUT LOGIN;

IF NOT EXISTS (SELECT * FROM sys.database_principals WHERE name = 'user_khachhang')
    CREATE USER user_khachhang WITHOUT LOGIN;
GO
-- Thêm user vào role
ALTER ROLE db_quantri ADD MEMBER user_quantri;
ALTER ROLE db_nhanvien ADD MEMBER user_nhanvien;  
ALTER ROLE db_khachhang ADD MEMBER user_khachhang;
GO