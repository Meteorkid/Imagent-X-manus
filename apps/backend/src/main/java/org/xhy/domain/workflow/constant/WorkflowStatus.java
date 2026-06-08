package org.xhy.domain.workflow.constant;

/**
 * 工作流状态枚举
 */
public enum WorkflowStatus {

    /**
     * 草稿状态
     */
    DRAFT("draft", "草稿"),

    /**
     * 已发布
     */
    PUBLISHED("published", "已发布"),

    /**
     * 已归档
     */
    ARCHIVED("archived", "已归档"),

    /**
     * 已禁用
     */
    DISABLED("disabled", "已禁用");

    private final String code;
    private final String description;

    WorkflowStatus(String code, String description) {
        this.code = code;
        this.description = description;
    }

    public String getCode() {
        return code;
    }

    public String getDescription() {
        return description;
    }

    public static WorkflowStatus fromCode(String code) {
        for (WorkflowStatus status : values()) {
            if (status.code.equals(code)) {
                return status;
            }
        }
        throw new IllegalArgumentException("Unknown workflow status: " + code);
    }
}
