package org.xhy.infrastructure.config;

import com.zaxxer.hikari.HikariConfig;
import com.zaxxer.hikari.HikariDataSource;
import org.springframework.boot.context.properties.ConfigurationProperties;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;

import javax.sql.DataSource;

/**
 * 数据库优化配置
 */
@Configuration
public class DatabaseOptimizationConfig {

    /**
     * 优化的 HikariCP 配置
     */
    @Bean
    @ConfigurationProperties(prefix = "spring.datasource.hikari")
    public HikariConfig hikariConfig() {
        HikariConfig config = new HikariConfig();

        // 连接池配置
        config.setPoolName("ImagentXHikariCP");
        config.setMaximumPoolSize(20);
        config.setMinimumIdle(5);
        config.setConnectionTimeout(30000);
        config.setIdleTimeout(600000);
        config.setMaxLifetime(1800000);

        // 连接测试
        config.setConnectionTestQuery("SELECT 1");
        config.setValidationTimeout(5000);

        // 泄漏检测
        config.setLeakDetectionThreshold(60000);

        // 连接初始化
        config.setConnectionInitSql("SET TIME ZONE 'Asia/Shanghai'");

        // 自动提交
        config.setAutoCommit(true);

        return config;
    }

    /**
     * 优化的数据源配置
     */
    @Bean
    public DataSource optimizedDataSource() {
        HikariConfig config = hikariConfig();
        return new HikariDataSource(config);
    }
}
