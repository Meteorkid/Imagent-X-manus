import cn.hutool.crypto.digest.BCrypt;

public class PasswordGenerator {
    public static void main(String[] args) {
        String password = "test123";
        String hash = BCrypt.hashpw(password);
        System.out.println("Password: " + password);
        System.out.println("Hash: " + hash);
        
        // 验证哈希是否正确
        boolean matches = BCrypt.checkpw(password, hash);
        System.out.println("Verification: " + matches);
    }
}
