-- BẢO MẬT CƠ SỞ DỮ LIỆU
USE QLVETHETHAO;
GO
-- Tạo schema riêng để quản lý bảo mật
IF NOT EXISTS (SELECT * FROM sys.schemas WHERE name = 'QuanLyVe')
    EXEC('CREATE SCHEMA QuanLyVe')
GO
-- Tạo view bảo mật để ẩn thông tin nhạy cảm của khách hàng
IF OBJECT_ID('QuanLyVe.vw_ThongTinKhachHangAnDanh', 'V') IS NOT NULL
    DROP VIEW QuanLyVe.vw_ThongTinKhachHangAnDanh;
GO
CREATE VIEW QuanLyVe.vw_ThongTinKhachHangAnDanh AS
SELECT 
    MaKhachHang,
    LEFT(HoTen, 1) + REPLICATE('*', LEN(HoTen)-1) AS HoTenAnDanh,
    LEFT(SoDienThoai, 3) + '****' + RIGHT(SoDienThoai, 3) AS SoDienThoaiAnDanh,
    NgayDangKy,
    DiemTichLuy,
    dbo.fn_HangKhachHang(MaKhachHang) AS HangKhachHang
FROM KHACHHANG;
GO
-- View bảo mật thông tin đơn vé (không hiển thị thông tin cá nhân chi tiết)
IF OBJECT_ID('QuanLyVe.vw_ThongKeDonVe', 'V') IS NOT NULL
    DROP VIEW QuanLyVe.vw_ThongKeDonVe;
GO
CREATE VIEW QuanLyVe.vw_ThongKeDonVe AS
SELECT 
    d.MaDonVe,
    d.ThoiGianDatVe,
    d.TongTien,
    d.TrangThai,
    s.TenSuKien,
    s.TheLoai,
    COUNT(ct.MaDonVe) AS SoVe,
    pv.TenPhongVe
FROM DONVE d
JOIN CHITIETVE ct ON d.MaDonVe = ct.MaDonVe
JOIN SUKIEN s ON ct.MaSuKien = s.MaSuKien
JOIN PHONGVE pv ON d.MaPhongVe = pv.MaPhongVe
GROUP BY d.MaDonVe, d.ThoiGianDatVe, d.TongTien, d.TrangThai, s.TenSuKien, s.TheLoai, pv.TenPhongVe;
GO
-- View bảo mật cho báo cáo doanh thu (chỉ hiển thị thông tin tổng hợp)
IF OBJECT_ID('QuanLyVe.vw_BaoCaoDoanhThuAnDanh', 'V') IS NOT NULL
    DROP VIEW QuanLyVe.vw_BaoCaoDoanhThuAnDanh;
GO
CREATE VIEW QuanLyVe.vw_BaoCaoDoanhThuAnDanh AS
SELECT 
    ThoiGianBaoCao,
    TongDoanhThu,
    SuKienBanChay
FROM BAOCAODOANHTHU;
GO
-- Phân quyền cho các view bảo mật
GRANT SELECT ON QuanLyVe.vw_ThongTinKhachHangAnDanh TO db_nhanvien;
GRANT SELECT ON QuanLyVe.vw_ThongKeDonVe TO db_nhanvien;
GRANT SELECT ON QuanLyVe.vw_BaoCaoDoanhThuAnDanh TO db_nhanvien;
GRANT SELECT ON QuanLyVe.vw_ThongKeDonVe TO db_khachhang;
GO
-- Revoke quyền truy cập trực tiếp vào bảng nhạy cảm từ nhân viên
REVOKE SELECT ON KHACHHANG FROM db_nhanvien;
REVOKE SELECT ON BAOCAODOANHTHU FROM db_nhanvien;
GO
-- Tạo stored procedure bảo mật để cập nhật thông tin khách hàng
IF OBJECT_ID('QuanLyVe.sp_CapNhatThongTinKhachHang', 'P') IS NOT NULL
    DROP PROCEDURE QuanLyVe.sp_CapNhatThongTinKhachHang;
GO
CREATE PROCEDURE QuanLyVe.sp_CapNhatThongTinKhachHang
    @MaKhachHang INT,
    @HoTen NVARCHAR(50),
    @SoDienThoai NVARCHAR(10),
    @DiaChi NVARCHAR(100)
AS
BEGIN
    -- Kiểm tra định dạng số điện thoại
    IF @SoDienThoai NOT LIKE '[0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9]'
    BEGIN
        RAISERROR(N'Số điện thoại không hợp lệ!', 16, 1);
        RETURN;
    END   
    UPDATE KHACHHANG 
    SET HoTen = @HoTen,
        SoDienThoai = @SoDienThoai,
        DiaChi = @DiaChi
    WHERE MaKhachHang = @MaKhachHang;
END;
GO
-- Phân quyền execute cho stored procedure bảo mật
GRANT EXECUTE ON QuanLyVe.sp_CapNhatThongTinKhachHang TO db_nhanvien;
GO