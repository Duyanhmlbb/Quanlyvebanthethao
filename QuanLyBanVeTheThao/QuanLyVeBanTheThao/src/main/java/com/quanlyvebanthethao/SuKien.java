package com.quanlyvebanthethao;

import java.util.Date;

public class SuKien {
    private int maSuKien;
    private String tenSuKien;
    private String theLoai;
    private String diaDiem;
    private Date thoiGian;
    private int giaVe;
    private int soLuongVe;
    
    public SuKien() {}
    
    public SuKien(int maSuKien, String tenSuKien, String theLoai, String diaDiem, 
                  Date thoiGian, int giaVe, int soLuongVe) {
        this.maSuKien = maSuKien;
        this.tenSuKien = tenSuKien;
        this.theLoai = theLoai;
        this.diaDiem = diaDiem;
        this.thoiGian = thoiGian;
        this.giaVe = giaVe;
        this.soLuongVe = soLuongVe;
    }
    
    public int getMaSuKien() { return maSuKien; }
    public void setMaSuKien(int maSuKien) { this.maSuKien = maSuKien; }
    
    public String getTenSuKien() { return tenSuKien; }
    public void setTenSuKien(String tenSuKien) { this.tenSuKien = tenSuKien; }
    
    public String getTheLoai() { return theLoai; }
    public void setTheLoai(String theLoai) { this.theLoai = theLoai; }
    
    public String getDiaDiem() { return diaDiem; }
    public void setDiaDiem(String diaDiem) { this.diaDiem = diaDiem; }
    
    public Date getThoiGian() { return thoiGian; }
    public void setThoiGian(Date thoiGian) { this.thoiGian = thoiGian; }
    
    public int getGiaVe() { return giaVe; }
    public void setGiaVe(int giaVe) { this.giaVe = giaVe; }
    
    public int getSoLuongVe() { return soLuongVe; }
    public void setSoLuongVe(int soLuongVe) { this.soLuongVe = soLuongVe; }
    
    @Override
    public String toString() {
        return "Ma SK: " + maSuKien + ", Ten: " + tenSuKien + ", Gia: " + giaVe + " VND";
    }
}