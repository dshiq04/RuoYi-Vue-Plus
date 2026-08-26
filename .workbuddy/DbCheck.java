import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.ResultSet;
import java.sql.Statement;

public class DbCheck {
    public static void main(String[] args) throws Exception {
        String url = "jdbc:mysql://192.168.150.10:3306/ruoyi_vue?useUnicode=true&characterEncoding=utf8&useSSL=true&serverTimezone=GMT%2B8&allowPublicKeyRetrieval=true";
        try (Connection conn = DriverManager.getConnection(url, "root", "tomori");
             Statement st = conn.createStatement()) {
            ResultSet rs = st.executeQuery(
                "SELECT user_id, user_name, nick_name, status, del_flag, password FROM sys_user WHERE user_name = 'admin'");
            while (rs.next()) {
                System.out.println("user_id=" + rs.getString(1)
                    + " user_name=" + rs.getString(2)
                    + " nick_name=" + rs.getString(3)
                    + " status=" + rs.getString(4)
                    + " del_flag=" + rs.getString(5));
                System.out.println("password_hash=" + rs.getString(6));
            }
        }
    }
}
