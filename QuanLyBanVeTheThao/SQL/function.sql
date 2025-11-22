--FUNCTIONS
USE QLVETHETHAO;
GO
--Tính tổng chi tiêu của khách hàng
IF OBJECT_ID('fn_TongChiTieu_KhachHang', 'FN') IS NOT NULL
    DROP FUNCTION fn_TongChiTieu_KhachHang;
GO
CREATE FUNCTION fn_TongChiTieu_KhachHang(@MaKhachHang INT)
RETURNS INT
AS
BEGIN
    DECLARE @Tong INT;
    SELECT @Tong = ISNULL(SUM(TongTien), 0)
    FROM DONVE 
    WHERE MaKhachHang = @MaKhachHang;
    RETURN @Tong;
END;
GO
--Xác định hạng khách hàng dựa trên điểm tích lũy
IF OBJECT_ID('fn_HangKhachHang', 'FN') IS NOT NULL
    DROP FUNCTION fn_HangKhachHang;
GO
CREATE FUNCTION fn_HangKhachHang(@MaKhachHang INT)
RETURNS NVARCHAR(20)
AS
BEGIN
    DECLARE @Diem INT, @Hang NVARCHAR(20);
    SELECT @Diem = DiemTichLuy FROM KHACHHANG WHERE MaKhachHang = @MaKhachHang;   
    IF @Diem >= 300 
        SET @Hang = N'Vàng';
    ELSE IF @Diem >= 150 
        SET @Hang = N'Bạc';
    ELSE 
        SET @Hang = N'Đồng';       
    RETURN @Hang;
END;
GO
--Tính số ghế còn trống theo sự kiện
IF OBJECT_ID('fn_SoGheConTrong', 'FN') IS NOT NULL
    DROP FUNCTION fn_SoGheConTrong;
GO
CREATE FUNCTION fn_SoGheConTrong(@MaSuKien INT)
RETURNS INT
AS
BEGIN
    DECLARE @TongGhe INT, @GheDaBan INT; 
    SELECT @TongGhe = COUNT(*) 
    FROM CHONGOI 
    WHERE MaSuKien = @MaSuKien;
    SELECT @GheDaBan = COUNT(DISTINCT ct.MaChoNgoi)
    FROM CHITIETVE ct
    JOIN DONVE d ON ct.MaDonVe = d.MaDonVe
    WHERE ct.MaSuKien = @MaSuKien;
    RETURN @TongGhe - @GheDaBan;
END;
GO