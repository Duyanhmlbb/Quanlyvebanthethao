--tạo bảng
use master;
go
if EXISTS (select * from sys.databases where name = 'QLVETHETHAO')
    drop database QLVETHETHAO;
go
create database QLVETHETHAO;
go
use QLVETHETHAO;
go
-- BẢNG PHÒNG VÉ
CREATE TABLE PHONGVE (
    MaPhongVe INT PRIMARY KEY,
    TenPhongVe NVARCHAR(100) NOT NULL,
    DiaChi NVARCHAR(100),
    SoDienThoai NVARCHAR(10)
);
-- BẢNG KHÁCH HÀNG
CREATE TABLE KHACHHANG (
    MaKhachHang int PRIMARY KEY,
    HoTen nvarchar(50) NOT NULL,
    SoDienThoai nvarchar(10) NOT NULL,
    DiaChi nvarchar(100),
    NgayDangKy date NOT NULL,
    DiemTichLuy int NOT NULL DEFAULT 0,
    CONSTRAINT CHK_KH_SODT CHECK (SoDienThoai LIKE '[0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9]'),
    CONSTRAINT CHK_KH_DIEM CHECK (DiemTichLuy >= 0)
);
-- BẢNG NHÀ TỔ CHỨC
CREATE TABLE NHATOCHUC (
    MaNhaToChuc int PRIMARY KEY,
    TenNhaToChuc nvarchar(100) NOT NULL,
    SoDienThoai nvarchar(10) NOT NULL,
    DiaChi nvarchar(100),
    LoaiSuKien nvarchar(100) NOT NULL,
    CONSTRAINT CHK_NTC_SODT CHECK (SoDienThoai LIKE '[0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9]')
);
-- BẢNG SỰ KIỆN
CREATE TABLE SUKIEN (
    MaSuKien int PRIMARY KEY,
    TenSuKien nvarchar(100) NOT NULL,
    TheLoai nvarchar(50) NOT NULL,
    DiaDiem nvarchar(100) NOT NULL,
    ThoiGian datetime NOT NULL,
    GiaVe int NOT NULL,
    SoLuongVe int NOT NULL,
    MaNhaToChuc int REFERENCES NHATOCHUC(MaNhaToChuc),
    CONSTRAINT CHK_SK_GIAVE CHECK (GiaVe > 0),
    CONSTRAINT CHK_SK_SOLUONG CHECK (SoLuongVe >= 0)
);
-- BẢNG ĐƠN VÉ
CREATE TABLE DONVE (
    MaDonVe int PRIMARY KEY,
    ThoiGianDatVe datetime NOT NULL,
    TongTien int NOT NULL,
    MaKhachHang int REFERENCES KHACHHANG(MaKhachHang),
    MaPhongVe int REFERENCES PHONGVE(MaPhongVe),
    TrangThai nvarchar(20) DEFAULT N'Đang xử lý',
    CONSTRAINT CHK_DV_TONGTIEN CHECK (TongTien >= 0),
    CONSTRAINT CHK_DV_TRANGTHAI CHECK (TrangThai IN (N'Đang xử lý', N'Hoàn thành', N'Hủy'))
);
-- BẢNG CHỖ NGỒI
CREATE TABLE CHONGOI (
    MaChoNgoi int PRIMARY KEY,
    MaSuKien int REFERENCES SUKIEN(MaSuKien),
    SoGhe nvarchar(10) NOT NULL,
    LoaiChoNgoi nvarchar(50) NOT NULL,
    TrangThai nvarchar(20) DEFAULT N'Trống',
    CONSTRAINT CHK_CN_TRANGTHAI CHECK (TrangThai IN (N'Trống', N'Đã đặt', N'Không sử dụng'))
);
-- BẢNG CHI TIẾT VÉ
CREATE TABLE CHITIETVE (
    MaSuKien int REFERENCES SUKIEN(MaSuKien),
    MaDonVe int REFERENCES DONVE(MaDonVe),
    SoLuong int NOT NULL,
    DonGia int NOT NULL,
    MaChoNgoi int REFERENCES CHONGOI(MaChoNgoi),
    CONSTRAINT PK_CHITIETVE PRIMARY KEY (MaSuKien, MaDonVe),
    CONSTRAINT CHK_CT_SOLUONG CHECK (SoLuong > 0),
    CONSTRAINT CHK_CT_DONGIA CHECK (DonGia >= 0)
);
-- BẢNG BÁO CÁO DOANH THU
CREATE TABLE BAOCAODOANHTHU (
    MaBaoCao int PRIMARY KEY,
    ThoiGianBaoCao date NOT NULL,
    TongDoanhThu int NOT NULL,
    SuKienBanChay nvarchar(100),
    MaDonVe int REFERENCES DONVE(MaDonVe),
    CONSTRAINT CHK_BCDT_DOANHTHU CHECK (TongDoanhThu >= 0)
);
-- BẢNG BÁO CÁO VÉ TỒN
CREATE TABLE BAOCAOVE (
    MaBaoCaoVe int PRIMARY KEY,
    ThoiGianBaoCao date NOT NULL,
    SuKienGanHetVe nvarchar(100),
    SuKienBanCham nvarchar(100),
    MaSuKien int REFERENCES SUKIEN(MaSuKien)
);
--Insert dữ liệu
-- PHÒNG VÉ
INSERT INTO PHONGVE VALUES 
(1, N'Phòng vé Mỹ Đình', N'Sân vận động Mỹ Đình', '0241234567'),
(2, N'Phòng vé Hà Đông', N'Nhà thi đấu Hà Đông', '0242345678'),
(3, N'Phòng vé trung tâm', N'234 Trần Duy Hưng', '0243456789');
-- KHÁCH HÀNG
INSERT INTO KHACHHANG VALUES 
(1, N'Mai Trọng Thế', '0392269573', N'Hà Đông', '2025-01-25', 120),
(2, N'Đỗ Nam Khánh', '0354952306', N'Vạn Phúc', '2025-03-13', 90),
(3, N'Lê Việt Anh', '0984881671', N'Hà Đông', '2025-05-21', 70),
(4, N'Nguyễn Trung Đức', '0397751851', N'Hoài Đức', '2024-07-06', 310),
(5, N'Phạm Duy Anh', '0977032874', N'Cầu Giấy', '2024-10-22', 250);
-- NHÀ TỔ CHỨC
INSERT INTO NHATOCHUC VALUES 
(1, N'Liên đoàn Bóng đá Hà Nội', '0361236734', N'Hà Nội', N'Bóng đá'),
(2, N'Hiệp hội Bóng rổ Việt Nam', '0323452118', N'Quận 7', N'Bóng rổ'),
(3, N'Ban tổ chức Giải Chạy VN', '0323236587', N'Nam Từ Liêm', N'Chạy bộ'),
(4, N'Giải Tennis Hà Nội', '0312569774', N'Bắc Từ Liêm', N'Tennis'),
(5, N'Liên đoàn Võ thuật VN', '0387543213', N'Cầu Giấy', N'Võ thuật');
-- SỰ KIỆN
INSERT INTO SUKIEN VALUES 
(1, N'Trận Bóng đá Hà Nội vs Hải Phòng', N'Bóng đá', N'Sân Mỹ Đình', '2025-02-20 19:00', 200000, 5000, 1),
(2, N'Giải Bóng rổ Hà Nội Cup', N'Bóng rổ', N'Nhà thi đấu Hà Đông', '2025-03-01 17:00', 150000, 1200, 2),
(3, N'Giải Chạy Marathon Mùa Xuân', N'Chạy bộ', N'Hồ Hoàn Kiếm', '2025-04-15 05:30', 300000, 800, 3),
(4, N'Giải Tennis Mở Rộng', N'Tennis', N'Sân Thanh Xuân', '2025-02-25 14:00', 250000, 400, 4),
(5, N'Giải Võ Thuật Toàn Quốc', N'Võ thuật', N'Nhà thi đấu Cầu Giấy', '2025-03-10 18:00', 180000, 1000, 5);
-- CHỖ NGỒI
INSERT INTO CHONGOI VALUES 
(1, 1, N'A01', N'VIP', N'Trống'),
(2, 1, N'A02', N'VIP', N'Trống'),
(3, 1, N'B15', N'Thường', N'Trống'),
(4, 2, N'C10', N'Khán đài chính', N'Trống'),
(5, 3, N'D05', N'Hạng 1', N'Trống'),
(6, 4, N'E20', N'Tiêu chuẩn', N'Trống'),
(7, 5, N'F07', N'VIP', N'Trống');
-- ĐƠN VÉ
INSERT INTO DONVE VALUES 
(1, '2025-02-10 09:30', 200000, 3, 1, N'Hoàn thành'),
(2, '2025-03-01 14:15', 300000, 1, 2, N'Hoàn thành'),
(3, '2025-04-02 10:00', 450000, 4, 1, N'Hoàn thành'),
(4, '2025-03-08 16:45', 500000, 5, 3, N'Hoàn thành'),
(5, '2025-02-18 11:20', 150000, 2, 2, N'Hoàn thành');
-- CHI TIẾT VÉ
INSERT INTO CHITIETVE VALUES 
(1, 1, 1, 200000, 1),
(2, 2, 2, 150000, 4),
(3, 3, 1, 300000, 5),
(4, 4, 2, 250000, 6),
(5, 5, 1, 150000, 7);
-- BÁO CÁO DOANH THU
INSERT INTO BAOCAODOANHTHU VALUES 
(1, '2025-02-28', 200000, N'Trận Bóng đá Hà Nội vs Hải Phòng', 1),
(2, '2025-03-31', 300000, N'Giải Bóng rổ Hà Nội Cup', 2),
(3, '2025-04-30', 900000, N'Giải Chạy Marathon Mùa Xuân', 3),
(4, '2025-02-28', 500000, N'Giải Tennis Mở Rộng', 4),
(5, '2025-03-31', 150000, N'Giải Bóng rổ Hà Nội Cup', 5);
-- BÁO CÁO VÉ TỒN
INSERT INTO BAOCAOVE VALUES 
(1, '2025-02-15', N'Trận Bóng đá Hà Nội vs Hải Phòng', N'Không có', 1),
(2, '2025-03-05', N'Giải Bóng rổ Hà Nội Cup', N'Không có', 2),
(3, '2025-04-10', N'Không có', N'Không có', 3),
(4, '2025-02-20', N'Giải Tennis Mở Rộng', N'Không có', 4),
(5, '2025-03-15', N'Không có', N'Không có', 5);