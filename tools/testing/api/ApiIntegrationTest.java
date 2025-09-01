package integration.tests.api;

import io.restassured.RestAssured;
import io.restassured.http.ContentType;
import org.junit.jupiter.api.BeforeAll;
import org.junit.jupiter.api.Test;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.boot.test.web.server.LocalServerPort;
import org.springframework.test.context.ActiveProfiles;

import static io.restassured.RestAssured.given;
import static org.hamcrest.Matchers.*;

/**
 * API集成测试
 */
@SpringBootTest(webEnvironment = SpringBootTest.WebEnvironment.RANDOM_PORT)
@ActiveProfiles("test")
public class ApiIntegrationTest {
    
    @LocalServerPort
    private int port;
    
    @BeforeAll
    static void setUp() {
        RestAssured.enableLoggingOfRequestAndResponseIfValidationFails();
    }
    
    @Test
    void testHealthCheck() {
        given()
            .port(port)
        .when()
            .get("/api/health")
        .then()
            .statusCode(200)
            .body("code", equalTo(200))
            .body("message", equalTo("ok"));
    }
    
    @Test
    void testAgentList() {
        given()
            .port(port)
            .header("Authorization", "Bearer test-token")
        .when()
            .get("/api/agents/published")
        .then()
            .statusCode(200)
            .body("code", equalTo(200));
    }
}
