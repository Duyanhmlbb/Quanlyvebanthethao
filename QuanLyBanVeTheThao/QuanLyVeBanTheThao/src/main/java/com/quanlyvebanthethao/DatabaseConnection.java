package com.quanlyvebanthethao;

import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.SQLException;
public class DatabaseConnection {
    private static final String URL = "jdbc:sqlserver://localhost:1433;databaseName=QLVETHETHAO;characterEncoding=UTF-8";
    private static final String USER = "sa";
    private static final String PASSWORD = "123456";
    public static Connection getConnection() throws SQLException {
        try {
            Class.forName("com.microsoft.sqlserver.jdbc.SQLServerDriver");
        } catch (ClassNotFoundException e) {
            throw new SQLException("Khong tim thay JDBC Driver", e);
        }
        return DriverManager.getConnection(URL, USER, PASSWORD);
    } 
    public static void testConnection() {
        try (Connection conn = getConnection()) {
            System.out.println("KET NOI THANH CONG DEN SQL SERVER");
            System.out.println("Database: " + conn.getMetaData().getDatabaseProductName());
            System.out.println("Phien ban: " + conn.getMetaData().getDatabaseProductVersion());
        } catch (SQLException e) {
            System.err.println("LOI KET NOI: " + e.getMessage());
        }
    }
}