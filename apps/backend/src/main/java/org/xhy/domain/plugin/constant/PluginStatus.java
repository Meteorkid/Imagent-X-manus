package org.xhy.domain.plugin.constant;

/**
 * 插件状态枚举
 */
public enum PluginStatus {

    /**
     * 已安装但未启用
     */
    INSTALLED("installed", "已安装"),

    /**
     * 已启用
     */
    ENABLED("enabled", "已启用"),

    /**
     * 已禁用
     */
    DISABLED("disabled", "已禁用"),

    /**
     * 加载中
     */
    LOADING("loading", "加载中"),

    /**
     * 运行中
     */
    RUNNING("running", "运行中"),

    /**
     * 错误状态
     */
    ERROR("error", "错误"),

    /**
     * 卸载中
     */
    UNINSTALLING("uninstalling", "卸载中");

    private final String code;
    private final String description;

    PluginStatus(String code, String description) {
        this.code = code;
        this.description = description;
    }

    public String getCode() {
        return code;
    }

    public String getDescription() {
        return description;
    }

    /**
     * 根据代码获取枚举
     */
    public static PluginStatus fromCode(String code) {
        for (PluginStatus status : values()) {
            if (status.code.equals(code)) {
                return status;
            }
        }
        throw new IllegalArgumentException("Unknown plugin status: " + code);
    }
}
