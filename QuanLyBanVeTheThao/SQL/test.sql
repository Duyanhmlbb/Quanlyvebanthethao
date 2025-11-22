--test
USE QLVETHETHAO;
GO
-- 1. KIỂM TRA BẢNG PHONGVE
PRINT '=== BẢNG PHONGVE ===';
SELECT * FROM PHONGVE;
GO
-- 2. KIỂM TRA BẢNG KHACHHANG
PRINT '=== BẢNG KHACHHANG ===';
SELECT * FROM KHACHHANG;
GO
-- 3. KIỂM TRA BẢNG NHATOCHUC
PRINT '=== BẢNG NHATOCHUC ===';
SELECT * FROM NHATOCHUC;
GO
-- 4. KIỂM TRA BẢNG SUKIEN
PRINT '=== BẢNG SUKIEN ===';
SELECT * FROM SUKIEN;
GO
-- 5. KIỂM TRA BẢNG DONVE
PRINT '=== BẢNG DONVE ===';
SELECT * FROM DONVE;
GO
-- 6. KIỂM TRA BẢNG CHONGOI
PRINT '=== BẢNG CHONGOI ===';
SELECT * FROM CHONGOI;
GO
-- 7. KIỂM TRA BẢNG CHITIETVE
PRINT '=== BẢNG CHITIETVE ===';
SELECT * FROM CHITIETVE;
GO
-- 8. KIỂM TRA BẢNG BAOCAODOANHTHU
PRINT '=== BẢNG BAOCAODOANHTHU ===';
SELECT * FROM BAOCAODOANHTHU;
GO
-- 9. KIỂM TRA BẢNG BAOCAOVE
PRINT '=== BẢNG BAOCAOVE ===';
SELECT * FROM BAOCAOVE;
GO
-- Test Index tìm sự kiện theo thời gian
SELECT * FROM SUKIEN WHERE ThoiGian > '2025-02-01';
-- Xem execution plan để thấy Index Seek thay vì Table Scan
-- Test View doanh thu
SELECT * FROM vw_DoanhThuTheoSuKien;
-- Test View ghế còn trống
SELECT * FROM vw_GheConTrongTheoSuKien WHERE MaSuKien = 1;
-- Test View thông tin đặt vé
SELECT * FROM vw_ThongTinDatVe WHERE MaKhachHang = 1;
-- Test tạo đơn vé mới
EXEC sp_TaoDonVe 
    @MaDonVe = 100,
    @ThoiGianDatVe = '2024-01-20 10:00:00',
    @TongTien = 400000,
    @MaKhachHang = 1,
    @MaPhongVe = 1,
    @MaSuKien = 1,
    @SoLuong = 2,
    @DonGia = 200000,
    @MaChoNgoi = 1;
-- Test báo cáo doanh thu
EXEC sp_BaoCaoDoanhThuTheoKhoangThoiGian 
    @NgayBatDau = '2025-01-01',
    @NgayKetThuc = '2025-12-31';
	-- Test tính tổng chi tiêu khách hàng
SELECT dbo.fn_TongChiTieu_KhachHang(1) AS TongChiTieu;
-- Test xếp hạng khách hàng
SELECT 
    HoTen,
    DiemTichLuy,
    dbo.fn_HangKhachHang(MaKhachHang) AS HangKhachHang
FROM KHACHHANG;
-- Test đếm ghế còn trống
SELECT dbo.fn_SoGheConTrong(1) AS GheConTrong;
-- Xem tất cả dữ liệu 
SELECT d.MaDonVe, d.MaKhachHang, ct.MaSuKien, ct.SoLuong, ct.MaChoNgoi
FROM DONVE d
LEFT JOIN CHITIETVE ct ON d.MaDonVe = ct.MaDonVe
WHERE d.MaDonVe IN (100,101,102,103,104)
ORDER BY d.MaDonVe;
-- Test quyền nhân viên (chạy với user_nhanvien)
EXECUTE AS USER = 'user_nhanvien';
SELECT * FROM vw_ThongTinDatVe;
SELECT * FROM KHACHHANG;     
REVERT;
--bảo mật.
-- Chuyển sang user nhân viên
EXECUTE AS USER = 'user_nhanvien';
PRINT '=== user_nhanvien - QUYỀN ĐƯỢC LÀM ===';
SELECT TOP 2 * FROM vw_ThongTinDatVe;
SELECT TOP 2 * FROM vw_GheConTrongTheoSuKien;
INSERT INTO DONVE (MaDonVe, ThoiGianDatVe, TongTien, MaKhachHang, MaPhongVe, TrangThai)
VALUES (150, GETDATE(), 300000, 1, 1, N'Đang xử lý');
INSERT INTO CHITIETVE (MaSuKien, MaDonVe, SoLuong, DonGia)
VALUES (1, 150, 1, 300000);
EXEC sp_TaoDonVe 
    @MaDonVe = 151,
    @ThoiGianDatVe = '2024-01-25 14:00:00',
    @TongTien = 400000,
    @MaKhachHang = 2,
    @MaPhongVe = 1,
    @MaSuKien = 2,
    @SoLuong = 2,
    @DonGia = 200000,
    @MaChoNgoi = NULL;
BEGIN TRY
    SELECT * FROM KHACHHANG;
END TRY
BEGIN CATCH
    PRINT 'Không được xem KHACHHANG: ' + ERROR_MESSAGE();
END CATCH
BEGIN TRY
    SELECT * FROM BAOCAODOANHTHU;
END TRY
BEGIN CATCH
    PRINT 'Không được xem BAOCAODOANHTHU: ' + ERROR_MESSAGE();
END CATCH
REVERT;
-- Test backup database
EXEC QuanLyVe.sp_BackupFullDatabase 
    @BackupPath = 'C:\Backup\QLVETHETHAO_Test.bak';
-- Xem lịch sử backup
SELECT * FROM QuanLyVe.vw_LichSuBackup;
-- Test phân tích hiệu suất
EXEC QuanLyVe.sp_PhanTichHieuSuat;
-- Test tối ưu database
EXEC QuanLyVe.sp_ToiUuDatabase;