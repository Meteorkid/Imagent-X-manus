package org.xhy.infrastructure.utils;

import org.junit.jupiter.api.Test;

import static org.junit.jupiter.api.Assertions.*;

class JwtUtilsTest {

    // 测试用的密钥（Base64 编码，长度足够）
    private static final String TEST_SECRET = "dGVzdC1zZWNyZXQta2V5LWZvci1qd3QtdG9rZW4tZ2VuZXJhdGlvbi0xMjM0NTY=";

    @Test
    void generateToken_ShouldReturnToken() {
        // Arrange
        JwtUtils jwtUtils = new JwtUtils(TEST_SECRET);
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
        JwtUtils jwtUtils = new JwtUtils(TEST_SECRET);
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
        JwtUtils jwtUtils = new JwtUtils(TEST_SECRET);
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
        JwtUtils jwtUtils = new JwtUtils(TEST_SECRET);
        String invalidToken = "invalid.token.here";

        // Act
        boolean isValid = jwtUtils.validateToken(invalidToken);

        // Assert
        assertFalse(isValid);
    }

    @Test
    void validateToken_WithEmptyToken_ShouldReturnFalse() {
        // Arrange
        JwtUtils jwtUtils = new JwtUtils(TEST_SECRET);
        String emptyToken = "";

        // Act
        boolean isValid = jwtUtils.validateToken(emptyToken);

        // Assert
        assertFalse(isValid);
    }

    @Test
    void getUserIdFromToken_WithDifferentTokens_ShouldReturnCorrectUserId() {
        // Arrange
        JwtUtils jwtUtils = new JwtUtils(TEST_SECRET);
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
