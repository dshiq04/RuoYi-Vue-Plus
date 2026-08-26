import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.ResultSet;
import java.sql.Statement;

public class CheckLatest {
    public static void main(String[] args) throws Exception {
        String myUrl = "jdbc:mysql://192.168.150.10:3306/ruoyi_vue?useUnicode=true&characterEncoding=utf8&useSSL=true&serverTimezone=GMT%2B8&allowPublicKeyRetrieval=true";
        try (Connection conn = DriverManager.getConnection(myUrl, "root", "tomori");
             Statement st = conn.createStatement()) {
            ResultSet rs = st.executeQuery(
                "SELECT info_id, user_name, msg, login_time FROM sys_logininfor ORDER BY info_id DESC LIMIT 3");
            System.out.println("[MySQL] 最近登录日志:");
            while (rs.next()) {
                System.out.println("  " + rs.getString(1) + " | " + rs.getString(2) + " | " + rs.getString(3) + " | " + rs.getString(4));
            }
            ResultSet rs2 = st.executeQuery("SELECT COUNT(*) FROM ai_conversation");
            rs2.next();
            System.out.println("[MySQL] ai_conversation 行数: " + rs2.getInt(1));
        }
        String pgUrl = "jdbc:postgresql://192.168.150.10:5432/ruoyi_vue";
        try (Connection conn = DriverManager.getConnection(pgUrl, "postgres", "tomori");
             Statement st = conn.createStatement()) {
            ResultSet rs = st.executeQuery(
                "SELECT info_id, user_name, msg, login_time FROM sys_logininfor ORDER BY info_id DESC LIMIT 3");
            System.out.println("[PG] 最近登录日志:");
            while (rs.next()) {
                System.out.println("  " + rs.getString(1) + " | " + rs.getString(2) + " | " + rs.getString(3) + " | " + rs.getString(4));
            }
        }
    }
}
