import cn.hutool.crypto.digest.BCrypt;

public class PasswordTest {
    public static void main(String[] args) {
        String password = "admin123";
        String hash = BCrypt.hashpw(password);
        System.out.println("Password: " + password);
        System.out.println("Hash: " + hash);
        
        // 测试验证
        boolean matches = BCrypt.checkpw(password, hash);
        System.out.println("Matches: " + matches);
        
        // 测试已知哈希
        String knownHash = "$2a$10$N.zmdr9k7uOCQb376NoUnuTJ8iAt6Z5EHsM8lE9lBOsl7iKTVEFDa";
        boolean matchesKnown = BCrypt.checkpw("123456", knownHash);
        System.out.println("Known hash matches '123456': " + matchesKnown);
    }
}

