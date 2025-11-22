package com.quanlyvebanthethao;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;

public class SuKienDAO {
    
    public List<SuKien> getAllSuKien() {
        List<SuKien> list = new ArrayList<>();
        String sql = "SELECT * FROM SUKIEN";
        
        try (Connection conn = DatabaseConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql);
             ResultSet rs = stmt.executeQuery()) {
            
            while (rs.next()) {
                SuKien sk = new SuKien();
                sk.setMaSuKien(rs.getInt("MaSuKien"));
                sk.setTenSuKien(rs.getString("TenSuKien"));
                sk.setTheLoai(rs.getString("TheLoai"));
                sk.setDiaDiem(rs.getString("DiaDiem"));
                sk.setThoiGian(rs.getTimestamp("ThoiGian"));
                sk.setGiaVe(rs.getInt("GiaVe"));
                sk.setSoLuongVe(rs.getInt("SoLuongVe"));
                list.add(sk);
            }
        } catch (SQLException e) {
            System.err.println("Loi lay su kien: " + e.getMessage());
        }
        return list;
    }
    
    public int getSoGheConTrong(int maSuKien) {
        String sql = "SELECT dbo.fn_SoGheConTrong(?) AS SoGheConTrong";
        
        try (Connection conn = DatabaseConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            
            stmt.setInt(1, maSuKien);
            ResultSet rs = stmt.executeQuery();
            
            if (rs.next()) {
                return rs.getInt("SoGheConTrong");
            }
        } catch (SQLException e) {
            System.err.println("Loi lay so ghe con trong: " + e.getMessage());
        }
        return 0;
    }
}