--Index
USE QLVETHETHAO;
Go
-- Tối ưu truy vấn tìm sự kiện theo thời gian
CREATE NONCLUSTERED INDEX IDX_SUKIEN_THOIGIAN ON SUKIEN(ThoiGian);
-- Tối ưu tìm đơn vé theo khách hàng
CREATE NONCLUSTERED INDEX IDX_DONVE_MAKH ON DONVE(MaKhachHang);
--  Tối ưu truy vấn chi tiết vé theo đơn
CREATE NONCLUSTERED INDEX IDX_CHITIETVE_MADONVE ON CHITIETVE(MaDonVe);
--  Tối ưu tìm chỗ ngồi theo sự kiện
CREATE NONCLUSTERED INDEX IDX_CHONGOI_MASUKIEN ON CHONGOI(MaSuKien);
--  Tối ưu thống kê doanh thu
CREATE NONCLUSTERED INDEX IDX_CT_MASUKIEN_DONGIA ON CHITIETVE(MaSuKien, DonGia);
-- Tối ưu tìm sự kiện theo thể loại
CREATE NONCLUSTERED INDEX IDX_SUKIEN_THELOAI ON SUKIEN(TheLoai);
-- Tối ưu tìm đơn vé theo trạng thái
CREATE NONCLUSTERED INDEX IDX_DONVE_TRANGTHAI ON DONVE(TrangThai);
-- Tối ưu tìm chỗ ngồi theo trạng thái
CREATE NONCLUSTERED INDEX IDX_CHONGOI_TRANGTHAI ON CHONGOI(TrangThai);
--  Tối ưu tìm khách hàng theo điểm tích lũy
CREATE NONCLUSTERED INDEX IDX_KHACHHANG_DIEM ON KHACHHANG(DiemTichLuy DESC);
--Tối ưu tìm đơn vé theo ngày đặt
CREATE NONCLUSTERED INDEX IDX_DONVE_NGAYDAT ON DONVE(ThoiGianDatVe DESC);