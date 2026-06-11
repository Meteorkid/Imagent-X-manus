package integration.tests.performance;

import io.restassured.RestAssured;
import org.junit.jupiter.api.Test;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.boot.test.web.server.LocalServerPort;
import org.springframework.test.context.ActiveProfiles;

import java.util.concurrent.TimeUnit;

import static io.restassured.RestAssured.given;
import static org.hamcrest.Matchers.lessThan;

/**
 * 性能测试
 */
@SpringBootTest(webEnvironment = SpringBootTest.WebEnvironment.RANDOM_PORT)
@ActiveProfiles("test")
public class PerformanceTest {
    
    @LocalServerPort
    private int port;
    
    @Test
    void testHealthCheckPerformance() {
        given()
            .port(port)
        .when()
            .get("/api/health")
        .then()
            .time(lessThan(200L), TimeUnit.MILLISECONDS)
            .statusCode(200);
    }
    
    @Test
    void testConcurrentRequests() {
        // 并发测试逻辑
        // 这里可以使用多线程或专门的并发测试工具
    }
}
