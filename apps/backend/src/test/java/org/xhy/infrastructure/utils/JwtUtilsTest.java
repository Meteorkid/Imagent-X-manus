package org.xhy.infrastructure.utils;

import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.junit.jupiter.MockitoExtension;
import org.springframework.test.util.ReflectionTestUtils;

import static org.junit.jupiter.api.Assertions.*;

@ExtendWith(MockitoExtension.class)
class JwtUtilsTest {

    private JwtUtils jwtUtils;

    // 测试用的密钥（Base64 编码，长度足够）
    private static final String TEST_SECRET = "dGVzdC1zZWNyZXQta2V5LWZvci1qd3QtdG9rZW4tZ2VuZXJhdGlvbi0xMjM0NTY=";

    @BeforeEach
    void setUp() {
        jwtUtils = new JwtUtils(TEST_SECRET);
    }

    @Test
    void generateToken_ShouldReturnToken() {
        // Arrange
        String userId = "user-123";

        // Act
        String token = jwtUtils.generateToken(userId);

        // Assert
        assertNotNull(token);
        assertFalse(token.isEmpty());
    }

    @Test
    void getUserIdFromToken_ShouldReturnUserId() {
        // Arrange
        String userId = "user-123";
        String token = jwtUtils.generateToken(userId);

        // Act
        String extractedUserId = jwtUtils.getUserIdFromToken(token);

        // Assert
        assertEquals(userId, extractedUserId);
    }

    @Test
    void validateToken_WithValidToken_ShouldReturnTrue() {
        // Arrange
        String userId = "user-123";
        String token = jwtUtils.generateToken(userId);

        // Act
        boolean isValid = jwtUtils.validateToken(token);

        // Assert
        assertTrue(isValid);
    }

    @Test
    void validateToken_WithInvalidToken_ShouldReturnFalse() {
        // Arrange
        String invalidToken = "invalid.token.here";

        // Act
        boolean isValid = jwtUtils.validateToken(invalidToken);

        // Assert
        assertFalse(isValid);
    }

    @Test
    void validateToken_WithEmptyToken_ShouldReturnFalse() {
        // Arrange
        String emptyToken = "";

        // Act
        boolean isValid = jwtUtils.validateToken(emptyToken);

        // Assert
        assertFalse(isValid);
    }

    @Test
    void constructor_WithEmptySecret_ShouldThrowException() {
        // Act & Assert
        assertThrows(IllegalStateException.class, () -> {
            new JwtUtils("");
        });
    }

    @Test
    void constructor_WithShortSecret_ShouldThrowException() {
        // Arrange
        String shortSecret = "short";

        // Act & Assert
        assertThrows(IllegalStateException.class, () -> {
            new JwtUtils(shortSecret);
        });
    }

    @Test
    void getUserIdFromToken_WithDifferentTokens_ShouldReturnCorrectUserId() {
        // Arrange
        String userId1 = "user-111";
        String userId2 = "user-222";
        String token1 = jwtUtils.generateToken(userId1);
        String token2 = jwtUtils.generateToken(userId2);

        // Act
        String extractedUserId1 = jwtUtils.getUserIdFromToken(token1);
        String extractedUserId2 = jwtUtils.getUserIdFromToken(token2);

        // Assert
        assertEquals(userId1, extractedUserId1);
        assertEquals(userId2, extractedUserId2);
        assertNotEquals(extractedUserId1, extractedUserId2);
    }
}
