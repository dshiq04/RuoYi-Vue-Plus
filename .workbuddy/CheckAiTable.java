import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.ResultSet;
import java.sql.Statement;

public class CheckAiTable {
    public static void main(String[] args) throws Exception {
        // 1. MySQL 主库是否存在 ai_conversation
        String myUrl = "jdbc:mysql://192.168.150.10:3306/ruoyi_vue?useUnicode=true&characterEncoding=utf8&useSSL=true&serverTimezone=GMT%2B8&allowPublicKeyRetrieval=true";
        try (Connection conn = DriverManager.getConnection(myUrl, "root", "tomori");
             Statement st = conn.createStatement()) {
            ResultSet rs = st.executeQuery("SHOW TABLES LIKE 'ai%'");
            System.out.println("[MySQL ruoyi_vue] ai 相关表:");
            boolean found = false;
            while (rs.next()) {
                System.out.println("  - " + rs.getString(1));
                found = true;
            }
            if (!found) System.out.println("  (无)");
        }
        // 2. PostgreSQL AI 库中的表
        String pgUrl = "jdbc:postgresql://192.168.150.10:5432/ruoyi_vue";
        try (Connection conn = DriverManager.getConnection(pgUrl, "postgres", "tomori");
             Statement st = conn.createStatement()) {
            ResultSet rs = st.executeQuery(
                "SELECT tablename FROM pg_tables WHERE schemaname = 'public' ORDER BY tablename");
            System.out.println("[PostgreSQL ruoyi_vue] public 表:");
            while (rs.next()) {
                System.out.println("  - " + rs.getString(1));
            }
        }
    }
}
