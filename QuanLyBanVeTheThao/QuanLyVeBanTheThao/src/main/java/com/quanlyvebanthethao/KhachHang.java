package com.quanlyvebanthethao;

import java.util.Date;

public class KhachHang {
    private int maKhachHang;
    private String hoTen;
    private String soDienThoai;
    private String diaChi;
    private Date ngayDangKy;
    private int diemTichLuy;
    
    public KhachHang() {}
    
    public KhachHang(int maKhachHang, String hoTen, String soDienThoai, 
                    String diaChi, Date ngayDangKy, int diemTichLuy) {
        this.maKhachHang = maKhachHang;
        this.hoTen = hoTen;
        this.soDienThoai = soDienThoai;
        this.diaChi = diaChi;
        this.ngayDangKy = ngayDangKy;
        this.diemTichLuy = diemTichLuy;
    }
    
    public int getMaKhachHang() { return maKhachHang; }
    public void setMaKhachHang(int maKhachHang) { this.maKhachHang = maKhachHang; }
    
    public String getHoTen() { return hoTen; }
    public void setHoTen(String hoTen) { this.hoTen = hoTen; }
    
    public String getSoDienThoai() { return soDienThoai; }
    public void setSoDienThoai(String soDienThoai) { this.soDienThoai = soDienThoai; }
    
    public String getDiaChi() { return diaChi; }
    public void setDiaChi(String diaChi) { this.diaChi = diaChi; }
    
    public Date getNgayDangKy() { return ngayDangKy; }
    public void setNgayDangKy(Date ngayDangKy) { this.ngayDangKy = ngayDangKy; }
    
    public int getDiemTichLuy() { return diemTichLuy; }
    public void setDiemTichLuy(int diemTichLuy) { this.diemTichLuy = diemTichLuy; }
    
    @Override
    public String toString() {
        return "Ma KH: " + maKhachHang + ", Ho ten: " + hoTen + ", SDT: " + soDienThoai + ", Diem: " + diemTichLuy;
    }
}