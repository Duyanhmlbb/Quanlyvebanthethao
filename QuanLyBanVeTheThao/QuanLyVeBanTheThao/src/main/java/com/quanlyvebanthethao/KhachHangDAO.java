package com.quanlyvebanthethao;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;

public class KhachHangDAO {
    
    public List<KhachHang> getAllKhachHang() {
        List<KhachHang> list = new ArrayList<>();
        String sql = "SELECT * FROM KHACHHANG";
        
        try (Connection conn = DatabaseConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql);
             ResultSet rs = stmt.executeQuery()) {
            
            while (rs.next()) {
                KhachHang kh = new KhachHang();
                kh.setMaKhachHang(rs.getInt("MaKhachHang"));
                kh.setHoTen(rs.getString("HoTen"));
                kh.setSoDienThoai(rs.getString("SoDienThoai"));
                kh.setDiaChi(rs.getString("DiaChi"));
                kh.setNgayDangKy(rs.getDate("NgayDangKy"));
                kh.setDiemTichLuy(rs.getInt("DiemTichLuy"));
                list.add(kh);
            }
        } catch (SQLException e) {
            System.err.println("Loi lay khach hang: " + e.getMessage());
        }
        return list;
    }
    
    public int getTongChiTieu(int maKhachHang) {
        String sql = "SELECT dbo.fn_TongChiTieu_KhachHang(?) AS TongChiTieu";
        
        try (Connection conn = DatabaseConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            
            stmt.setInt(1, maKhachHang);
            ResultSet rs = stmt.executeQuery();
            
            if (rs.next()) {
                return rs.getInt("TongChiTieu");
            }
        } catch (SQLException e) {
            System.err.println("Loi lay tong chi tieu: " + e.getMessage());
        }
        return 0;
    }
    
    public String getHangKhachHang(int maKhachHang) {
        String sql = "SELECT dbo.fn_HangKhachHang(?) AS HangKhachHang";
        
        try (Connection conn = DatabaseConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            
            stmt.setInt(1, maKhachHang);
            ResultSet rs = stmt.executeQuery();
            
            if (rs.next()) {
                return rs.getString("HangKhachHang");
            }
        } catch (SQLException e) {
            System.err.println("Loi lay hang khach hang: " + e.getMessage());
        }
        return "Dong";
    }
}