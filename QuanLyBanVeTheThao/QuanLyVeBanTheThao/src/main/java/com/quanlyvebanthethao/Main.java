package com.quanlyvebanthethao;
import java.util.List;
public class Main {
    public static void main(String[] args) {
        System.out.println("HE THONG QUAN LY VE BAN THE THAO");
        System.out.println("=================================");
        
        DatabaseConnection.testConnection();
        
        KhachHangDAO khachHangDAO = new KhachHangDAO();
        SuKienDAO suKienDAO = new SuKienDAO();
        
        System.out.println("\nDANH SACH KHACH HANG:");
        List<KhachHang> dsKhachHang = khachHangDAO.getAllKhachHang();
        for (KhachHang kh : dsKhachHang) {
            String hang = khachHangDAO.getHangKhachHang(kh.getMaKhachHang());
            System.out.println(kh + " - Hang: " + hang);
        }
        
        System.out.println("\nDANH SACH SU KIEN:");
        List<SuKien> dsSuKien = suKienDAO.getAllSuKien();
        for (SuKien sk : dsSuKien) {
            int gheConTrong = suKienDAO.getSoGheConTrong(sk.getMaSuKien());
            System.out.println(sk + " - Ghe con: " + gheConTrong);
        }
        
        if (!dsKhachHang.isEmpty()) {
            int tongChiTieu = khachHangDAO.getTongChiTieu(dsKhachHang.get(0).getMaKhachHang());
            System.out.println("\nTong chi tieu KH dau tien: " + tongChiTieu + " VND");
        }
        
        System.out.println("\nKET THUC CHUONG TRINH");
    }
}