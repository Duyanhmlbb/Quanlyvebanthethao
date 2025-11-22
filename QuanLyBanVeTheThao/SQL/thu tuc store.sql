--Thủ tục
USE QLVETHETHAO;
GO
--Tạo đơn vé mới với kiểm tra ràng buộc
IF OBJECT_ID('sp_TaoDonVe', 'P') IS NOT NULL
    DROP PROCEDURE sp_TaoDonVe;
GO
CREATE PROCEDURE sp_TaoDonVe
    @MaDonVe INT,
    @ThoiGianDatVe DATETIME,
    @TongTien INT,
    @MaKhachHang INT,
    @MaPhongVe INT,
    @MaSuKien INT,
    @SoLuong INT,
    @DonGia INT,
    @MaChoNgoi INT = NULL
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRANSACTION;
    BEGIN TRY
        -- Kiểm tra chỗ ngồi còn trống không
        IF @MaChoNgoi IS NOT NULL 
        BEGIN
            IF EXISTS (SELECT 1 FROM CHITIETVE WHERE MaChoNgoi = @MaChoNgoi AND MaSuKien = @MaSuKien)
            BEGIN
                RAISERROR(N'Chỗ ngồi đã được đặt!', 16, 1);
                ROLLBACK TRANSACTION;
                RETURN;
            END
        END
        -- Kiểm tra số lượng vé
        DECLARE @VeDaBan INT;
        SELECT @VeDaBan = ISNULL(SUM(SoLuong), 0) FROM CHITIETVE WHERE MaSuKien = @MaSuKien;   
        DECLARE @TongVe INT;
        SELECT @TongVe = SoLuongVe FROM SUKIEN WHERE MaSuKien = @MaSuKien;     
        IF (@VeDaBan + @SoLuong) > @TongVe
        BEGIN
            RAISERROR(N'Số lượng vé không đủ!', 16, 1);
            ROLLBACK TRANSACTION;
            RETURN;
        END
        -- Thêm đơn vé
        INSERT INTO DONVE (MaDonVe, ThoiGianDatVe, TongTien, MaKhachHang, MaPhongVe, TrangThai)
        VALUES (@MaDonVe, @ThoiGianDatVe, @TongTien, @MaKhachHang, @MaPhongVe, N'Hoàn thành'); 
        -- Thêm chi tiết vé
        INSERT INTO CHITIETVE (MaSuKien, MaDonVe, SoLuong, DonGia, MaChoNgoi)
        VALUES (@MaSuKien, @MaDonVe, @SoLuong, @DonGia, @MaChoNgoi);
        -- Cập nhật điểm tích lũy
        UPDATE KHACHHANG
        SET DiemTichLuy = DiemTichLuy + (@TongTien / 10000)
        WHERE MaKhachHang = @MaKhachHang;
        -- Cập nhật trạng thái chỗ ngồi
        IF @MaChoNgoi IS NOT NULL
        BEGIN
            UPDATE CHONGOI SET TrangThai = N'Đã đặt' WHERE MaChoNgoi = @MaChoNgoi;
        END
        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        ROLLBACK TRANSACTION;
        DECLARE @ErrorMessage NVARCHAR(4000) = ERROR_MESSAGE();
        RAISERROR(@ErrorMessage, 16, 1);
    END CATCH
END;
GO
-- Báo cáo doanh thu theo khoảng thời gian
IF OBJECT_ID('sp_BaoCaoDoanhThuTheoKhoangThoiGian', 'P') IS NOT NULL
    DROP PROCEDURE sp_BaoCaoDoanhThuTheoKhoangThoiGian;
GO
CREATE PROCEDURE sp_BaoCaoDoanhThuTheoKhoangThoiGian
    @NgayBatDau DATE,
    @NgayKetThuc DATE
AS
BEGIN
    SELECT 
        s.MaSuKien, 
        s.TenSuKien, 
        s.TheLoai,
        SUM(ct.SoLuong * ct.DonGia) AS TongDoanhThu,
        COUNT(DISTINCT d.MaDonVe) AS SoDonHang,
        AVG(ct.DonGia) AS GiaVeTrungBinh
    FROM SUKIEN s
    JOIN CHITIETVE ct ON s.MaSuKien = ct.MaSuKien
    JOIN DONVE d ON ct.MaDonVe = d.MaDonVe
    WHERE d.ThoiGianDatVe BETWEEN @NgayBatDau AND @NgayKetThuc
    GROUP BY s.MaSuKien, s.TenSuKien, s.TheLoai
    ORDER BY TongDoanhThu DESC;
END;
GO