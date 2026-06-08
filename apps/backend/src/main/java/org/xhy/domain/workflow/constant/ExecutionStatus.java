package org.xhy.domain.workflow.constant;

/**
 * 工作流执行状态枚举
 */
public enum ExecutionStatus {

    /**
     * 等待执行
     */
    PENDING("pending", "等待执行"),

    /**
     * 执行中
     */
    RUNNING("running", "执行中"),

    /**
     * 已完成
     */
    COMPLETED("completed", "已完成"),

    /**
     * 执行失败
     */
    FAILED("failed", "执行失败"),

    /**
     * 已取消
     */
    CANCELLED("cancelled", "已取消"),

    /**
     * 暂停中
     */
    PAUSED("paused", "暂停中");

    private final String code;
    private final String description;

    ExecutionStatus(String code, String description) {
        this.code = code;
        this.description = description;
    }

    public String getCode() {
        return code;
    }

    public String getDescription() {
        return description;
    }

    public static ExecutionStatus fromCode(String code) {
        for (ExecutionStatus status : values()) {
            if (status.code.equals(code)) {
                return status;
            }
        }
        throw new IllegalArgumentException("Unknown execution status: " + code);
    }
}
