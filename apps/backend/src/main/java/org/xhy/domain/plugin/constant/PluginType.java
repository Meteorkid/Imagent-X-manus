package org.xhy.domain.plugin.constant;

/**
 * 插件类型枚举
 */
public enum PluginType {

    /**
     * 工具插件 - 提供额外的工具功能
     */
    TOOL("tool", "工具插件"),

    /**
     * 连接器插件 - 连接外部服务
     */
    CONNECTOR("connector", "连接器插件"),

    /**
     * 处理器插件 - 数据处理和转换
     */
    PROCESSOR("processor", "处理器插件"),

    /**
     * 扩展插件 - 系统功能扩展
     */
    EXTENSION("extension", "扩展插件"),

    /**
     * UI插件 - 用户界面扩展
     */
    UI("ui", "UI插件");

    private final String code;
    private final String description;

    PluginType(String code, String description) {
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
    public static PluginType fromCode(String code) {
        for (PluginType type : values()) {
            if (type.code.equals(code)) {
                return type;
            }
        }
        throw new IllegalArgumentException("Unknown plugin type: " + code);
    }
}
