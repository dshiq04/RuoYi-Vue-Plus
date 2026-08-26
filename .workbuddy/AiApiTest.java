import java.io.InputStream;
import java.io.OutputStream;
import java.net.Socket;
import javax.crypto.Cipher;
import javax.crypto.spec.SecretKeySpec;
import java.net.URI;
import java.net.http.HttpClient;
import java.net.http.HttpRequest;
import java.net.http.HttpResponse;
import java.nio.charset.StandardCharsets;
import java.nio.file.Files;
import java.nio.file.Path;
import java.security.KeyFactory;
import java.security.PrivateKey;
import java.security.PublicKey;
import java.security.SecureRandom;
import java.security.spec.PKCS8EncodedKeySpec;
import java.security.spec.X509EncodedKeySpec;
import java.util.Base64;

/**
 * AI 接口测试脚本 (模拟前端加密流程)
 * 用法:
 *   java AiApiTest captcha            -> 获取验证码 保存图片到 captcha.png 并输出 uuid
 *   java AiApiTest login <code> <uuid> -> 带验证码登录 输出 token
 */
public class AiApiTest {

    static final String RSA_PUBLIC_KEY = "MFwwDQYJKoZIhvcNAQEBBQADSwAwSAJBAKoR8mX0rGKLqzcWmOzbfj64K8ZIgOdHnzkXSOVOZbFu/TJhZ7rFAN+eaGkl3C4buccQd/EjEsj9ir7ijT7h96MCAwEAAQ==";
    static final String RSA_PRIVATE_KEY = "MIIBVAIBADANBgkqhkiG9w0BAQEFAASCAT4wggE6AgEAAkEAqhHyZfSsYourNxaY7Nt+PrgrxkiA50efORdI5U5lsW79MmFnusUA355oaSXcLhu5xxB38SMSyP2KvuKNPuH3owIDAQABAkAfoiLyL+Z4lf4Myxk6xUDgLaWGximj20CUf+5BKKnlrK+Ed8gAkM0HqoTt2UZwA5E2MzS4EI2gjfQhz5X28uqxAiEA3wNFxfrCZlSZHb0gn2zDpWowcSxQAgiCstxGUoOqlW8CIQDDOerGKH5OmCJ4Z21v+F25WaHYPxCFMvwxpcw99EcvDQIgIdhDTIqD2jfYjPTY8Jj3EDGPbH2HHuffvflECt3Ek60CIQCFRlCkHpi7hthhYhovyloRYsM+IS9h/0BzlEAuO0ktMQIgSPT3aFAgJYwKpqRYKlLDVcflZFCKY7u3UP8iWi1Qw0Y=";
    static final String BASE = "http://localhost:8080";
    static final String CLIENT_ID = "e5cd7e4891bf95d1d19206ce24a7b32e";

    public static void main(String[] args) throws Exception {
        HttpClient client = HttpClient.newHttpClient();
        if ("captcha".equals(args[0])) {
            HttpRequest request = HttpRequest.newBuilder().uri(URI.create(BASE + "/auth/code"))
                .header("clientid", CLIENT_ID).GET().build();
            HttpResponse<String> resp = client.send(request, HttpResponse.BodyHandlers.ofString(StandardCharsets.UTF_8));
            String body = resp.body();
            Files.writeString(Path.of("captcha_raw.json"), body);
            // 提取 uuid 与 img
            String uuid = extract(body, "\"uuid\":\"");
            String img = extract(body, "\"img\":\"");
            Files.write(Path.of("captcha.png"), Base64.getDecoder().decode(img));
            System.out.println("UUID=" + uuid);
            System.out.println("captcha.png saved");
        } else if ("peek".equals(args[0])) {
            // 直连 Redis 读取验证码真实值: java AiApiTest peek <uuid>
            try (Socket socket = new Socket("192.168.150.10", 6379)) {
                OutputStream out = socket.getOutputStream();
                InputStream in = socket.getInputStream();
                send(out, "AUTH", "tomori");
                System.out.println("AUTH -> " + readLine(in));
                send(out, "SELECT", "6");
                System.out.println("SELECT -> " + readLine(in));
                send(out, "GET", "GLOBAL:CAPTCHA_CODES:" + args[1]);
                String status = readLine(in);
                System.out.println("GET status -> " + status);
                if (status != null && status.startsWith("$")) {
                    int len = Integer.parseInt(status.substring(1));
                    if (len >= 0) {
                        byte[] buf = new byte[len];
                        int read = 0;
                        while (read < len) {
                            read += in.read(buf, read, len - read);
                        }
                        in.read(); in.read(); // \r\n
                        System.out.println("VALUE -> " + new String(buf, StandardCharsets.UTF_8));
                    }
                }
            }
        } else if ("login".equals(args[0])) {
            String code = args[1];
            String uuid = args[2];
            String body = "{\"clientId\":\"" + CLIENT_ID + "\",\"grantType\":\"password\",\"tenantId\":\"000000\","
                + "\"username\":\"admin\",\"password\":\"666666\",\"code\":\"" + code + "\",\"uuid\":\"" + uuid + "\"}";
            System.out.println(postEncrypted(client, "/auth/login", body));
        }
    }

    static void send(OutputStream out, String... args) throws Exception {
        StringBuilder sb = new StringBuilder("*" + args.length + "\r\n");
        for (String arg : args) {
            sb.append('$').append(arg.getBytes(StandardCharsets.UTF_8).length).append("\r\n").append(arg).append("\r\n");
        }
        out.write(sb.toString().getBytes(StandardCharsets.UTF_8));
        out.flush();
    }

    static String readLine(InputStream in) throws Exception {
        StringBuilder sb = new StringBuilder();
        int c;
        while ((c = in.read()) != -1) {
            if (c == '\r') {
                in.read();
                break;
            }
            sb.append((char) c);
        }
        return sb.toString();
    }

    static String extract(String json, String key) {
        int start = json.indexOf(key) + key.length();
        int end = json.indexOf("\"", start);
        return json.substring(start, end);
    }

    /** 模拟前端加密: AES/ECB 加密 body, RSA 加密 AES key 放 encrypt-key 头 */
    static String postEncrypted(HttpClient client, String path, String body) throws Exception {
        String chars = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789";
        SecureRandom random = new SecureRandom();
        StringBuilder sb = new StringBuilder();
        for (int i = 0; i < 32; i++) {
            sb.append(chars.charAt(random.nextInt(chars.length())));
        }
        String aesKey = sb.toString();

        Cipher aes = Cipher.getInstance("AES/ECB/PKCS5Padding");
        aes.init(Cipher.ENCRYPT_MODE, new SecretKeySpec(aesKey.getBytes(StandardCharsets.UTF_8), "AES"));
        String encBody = Base64.getEncoder().encodeToString(aes.doFinal(body.getBytes(StandardCharsets.UTF_8)));

        byte[] keyBytes = Base64.getDecoder().decode(RSA_PUBLIC_KEY);
        PublicKey publicKey = KeyFactory.getInstance("RSA").generatePublic(new X509EncodedKeySpec(keyBytes));
        Cipher rsa = Cipher.getInstance("RSA/ECB/PKCS1Padding");
        rsa.init(Cipher.ENCRYPT_MODE, publicKey);
        String encKey = Base64.getEncoder().encodeToString(
            rsa.doFinal(Base64.getEncoder().encodeToString(aesKey.getBytes(StandardCharsets.UTF_8)).getBytes(StandardCharsets.UTF_8)));

        // 本地自解密验证 (模拟后端 DecryptRequestBodyWrapper)
        PrivateKey privateKey = KeyFactory.getInstance("RSA")
            .generatePrivate(new PKCS8EncodedKeySpec(Base64.getDecoder().decode(RSA_PRIVATE_KEY)));
        Cipher rsaDec = Cipher.getInstance("RSA/ECB/PKCS1Padding");
        rsaDec.init(Cipher.DECRYPT_MODE, privateKey);
        String aesKeyRecovered = new String(Base64.getDecoder().decode(
            new String(rsaDec.doFinal(Base64.getDecoder().decode(encKey)), StandardCharsets.UTF_8)), StandardCharsets.UTF_8);
        Cipher aesDec = Cipher.getInstance("AES/ECB/PKCS5Padding");
        aesDec.init(Cipher.DECRYPT_MODE, new SecretKeySpec(aesKeyRecovered.getBytes(StandardCharsets.UTF_8), "AES"));
        String plainBody = new String(aesDec.doFinal(Base64.getDecoder().decode(encBody)), StandardCharsets.UTF_8);
        System.out.println("[SELF-DECRYPT] " + plainBody);

        HttpRequest request = HttpRequest.newBuilder()
            .uri(URI.create(BASE + path))
            .header("Content-Type", "application/json;charset=utf-8")
            .header("clientid", CLIENT_ID)
            .header("encrypt-key", encKey)
            .POST(HttpRequest.BodyPublishers.ofString(encBody, StandardCharsets.UTF_8))
            .build();
        HttpResponse<String> resp = client.send(request, HttpResponse.BodyHandlers.ofString(StandardCharsets.UTF_8));
        return "HTTP " + resp.statusCode() + "\n" + resp.body();
    }
}
