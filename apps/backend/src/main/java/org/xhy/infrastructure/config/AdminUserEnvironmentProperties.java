package org.xhy.infrastructure.config;

import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Component;

/** Imagent X管理员用户环境变量配置
 * 
 * 支持通过环境变量配置管理员和测试用户信息
 * 环境变量格式：IMAGENTX_ADMIN_EMAIL, IMAGENTX_ADMIN_PASSWORD, IMAGENTX_ADMIN_NICKNAME, IMAGENTX_TEST_ENABLED
 * 
 * @author xhy */
@Component
public class AdminUserEnvironmentProperties {

    /** 管理员邮箱 */
    @Value("${IMAGENTX_ADMIN_EMAIL:admin@imagentx.ai}")
    private String adminEmail;

    /** 管理员密码 */
    @Value("${IMAGENTX_ADMIN_PASSWORD:admin123}")
    private String adminPassword;

    /** 管理员昵称 */
    @Value("${IMAGENTX_ADMIN_NICKNAME:Imagent X管理员}")
    private String adminNickname;

    /** 是否启用测试用户 */
    @Value("${IMAGENTX_TEST_ENABLED:true}")
    private Boolean testEnabled;

    /** 测试用户邮箱 */
    @Value("${IMAGENTX_TEST_EMAIL:test@imagentx.ai}")
    private String testEmail;

    /** 测试用户密码 */
    @Value("${IMAGENTX_TEST_PASSWORD:test123}")
    private String testPassword;

    /** 测试用户昵称 */
    @Value("${IMAGENTX_TEST_NICKNAME:测试用户}")
    private String testNickname;

    public String getAdminEmail() {
        return adminEmail;
    }

    public String getAdminPassword() {
        return adminPassword;
    }

    public String getAdminNickname() {
        return adminNickname;
    }

    public Boolean getTestEnabled() {
        return testEnabled;
    }

    public String getTestEmail() {
        return testEmail;
    }

    public String getTestPassword() {
        return testPassword;
    }

    public String getTestNickname() {
        return testNickname;
    }
}