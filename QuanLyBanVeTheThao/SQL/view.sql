-- VIEWS
USE QLVETHETHAO;
GO
--Thống kê doanh thu theo từng sự kiện
IF OBJECT_ID('vw_DoanhThuTheoSuKien', 'V') IS NOT NULL
    DROP VIEW vw_DoanhThuTheoSuKien;
GO
CREATE VIEW vw_DoanhThuTheoSuKien AS
SELECT 
    s.MaSuKien, 
    s.TenSuKien, 
    s.TheLoai,
    SUM(ct.SoLuong * ct.DonGia) AS TongDoanhThu,
    COUNT(DISTINCT d.MaDonVe) AS SoDonHang
FROM SUKIEN s
LEFT JOIN CHITIETVE ct ON s.MaSuKien = ct.MaSuKien
LEFT JOIN DONVE d ON ct.MaDonVe = d.MaDonVe
GROUP BY s.MaSuKien, s.TenSuKien, s.TheLoai;
GO
-- Hiển thị thông tin đặt vé chi tiết
IF OBJECT_ID('vw_ThongTinDatVe', 'V') IS NOT NULL
    DROP VIEW vw_ThongTinDatVe;
GO
CREATE VIEW vw_ThongTinDatVe AS
SELECT 
    d.MaDonVe, 
    d.ThoiGianDatVe, 
    d.TongTien, 
    d.TrangThai,
    k.MaKhachHang, 
    k.HoTen AS TenKhachHang, 
    k.SoDienThoai,
    ct.MaSuKien, 
    s.TenSuKien, 
    s.ThoiGian AS ThoiGianSuKien,
    ct.SoLuong, 
    ct.DonGia, 
    co.SoGhe, 
    co.LoaiChoNgoi,
    pv.TenPhongVe
FROM DONVE d
JOIN KHACHHANG k ON d.MaKhachHang = k.MaKhachHang
JOIN CHITIETVE ct ON d.MaDonVe = ct.MaDonVe
LEFT JOIN SUKIEN s ON ct.MaSuKien = s.MaSuKien
LEFT JOIN CHONGOI co ON ct.MaChoNgoi = co.MaChoNgoi
LEFT JOIN PHONGVE pv ON d.MaPhongVe = pv.MaPhongVe;
GO
-- vw_GheConTrongTheoSuKien: Hiển thị số ghế còn trống theo sự kiện
IF OBJECT_ID('vw_GheConTrongTheoSuKien', 'V') IS NOT NULL
    DROP VIEW vw_GheConTrongTheoSuKien;
GO
CREATE VIEW vw_GheConTrongTheoSuKien AS
SELECT 
    s.MaSuKien, 
    s.TenSuKien, 
    co.LoaiChoNgoi,
    COUNT(co.MaChoNgoi) AS TongGhe,
    SUM(CASE WHEN ct.MaChoNgoi IS NOT NULL THEN 1 ELSE 0 END) AS GheDaBan,
    COUNT(co.MaChoNgoi) - SUM(CASE WHEN ct.MaChoNgoi IS NOT NULL THEN 1 ELSE 0 END) AS GheConLai
FROM CHONGOI co
LEFT JOIN CHITIETVE ct ON co.MaChoNgoi = ct.MaChoNgoi
LEFT JOIN SUKIEN s ON co.MaSuKien = s.MaSuKien
GROUP BY s.MaSuKien, s.TenSuKien, co.LoaiChoNgoi;
GO
-- PHÂN QUYỀN VIEWS
-- Đảm bảo roles đã tồn tại
IF NOT EXISTS (SELECT * FROM sys.database_principals WHERE name = 'db_quantri')
    CREATE ROLE db_quantri;
IF NOT EXISTS (SELECT * FROM sys.database_principals WHERE name = 'db_nhanvien')  
    CREATE ROLE db_nhanvien;
IF NOT EXISTS (SELECT * FROM sys.database_principals WHERE name = 'db_khachhang')
    CREATE ROLE db_khachhang;
GO
-- Phân quyền views cho quản trị viên
GRANT SELECT ON vw_DoanhThuTheoSuKien TO db_quantri;
GRANT SELECT ON vw_ThongTinDatVe TO db_quantri;
GRANT SELECT ON vw_GheConTrongTheoSuKien TO db_quantri;
GO
-- Phân quyền views cho nhân viên
GRANT SELECT ON vw_ThongTinDatVe TO db_nhanvien;
GRANT SELECT ON vw_GheConTrongTheoSuKien TO db_nhanvien;
GO
-- Phân quyền views cho khách hàng
GRANT SELECT ON vw_GheConTrongTheoSuKien TO db_khachhang;
GO