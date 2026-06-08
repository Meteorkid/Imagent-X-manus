import { apiRequest } from "./api"

/**
 * 工作流接口
 */
export interface Workflow {
  id: string
  name: string
  description: string
  version: string
  definition: string
  status: string
  createdBy: string
  tags: string[]
  config: Record<string, any>
  createdAt: string
  updatedAt: string
  lastExecutedAt: string
  executionCount: number
}

/**
 * 工作流执行记录接口
 */
export interface WorkflowExecution {
  id: string
  workflowId: string
  status: string
  inputs: Record<string, any>
  outputs: Record<string, any>
  currentNodeId: string
  errorMessage: string
  startTime: string
  endTime: string
  duration: number
  retryCount: number
  executedBy: string
}

/**
 * 获取所有工作流
 */
export async function getWorkflows() {
  return apiRequest<Workflow[]>("/api/workflows")
}

/**
 * 获取工作流详情
 */
export async function getWorkflow(workflowId: string) {
  return apiRequest<Workflow>(`/api/workflows/${workflowId}`)
}

/**
 * 创建工作流
 */
export async function createWorkflow(data: {
  name: string
  description?: string
  definition: string
}) {
  return apiRequest<Workflow>("/api/workflows", {
    method: "POST",
    body: JSON.stringify(data),
  })
}

/**
 * 更新工作流
 */
export async function updateWorkflow(workflowId: string, data: Partial<Workflow>) {
  return apiRequest<Workflow>(`/api/workflows/${workflowId}`, {
    method: "PUT",
    body: JSON.stringify(data),
  })
}

/**
 * 删除工作流
 */
export async function deleteWorkflow(workflowId: string) {
  return apiRequest<void>(`/api/workflows/${workflowId}`, {
    method: "DELETE",
  })
}

/**
 * 发布工作流
 */
export async function publishWorkflow(workflowId: string) {
  return apiRequest<void>(`/api/workflows/${workflowId}/publish`, {
    method: "POST",
  })
}

/**
 * 归档工作流
 */
export async function archiveWorkflow(workflowId: string) {
  return apiRequest<void>(`/api/workflows/${workflowId}/archive`, {
    method: "POST",
  })
}

/**
 * 执行工作流
 */
export async function executeWorkflow(workflowId: string, inputs: Record<string, any> = {}) {
  return apiRequest<WorkflowExecution>(`/api/workflows/${workflowId}/execute`, {
    method: "POST",
    body: JSON.stringify({ inputs }),
  })
}

/**
 * 获取执行记录
 */
export async function getExecution(executionId: string) {
  return apiRequest<WorkflowExecution>(`/api/workflows/executions/${executionId}`)
}

/**
 * 获取工作流的所有执行记录
 */
export async function getWorkflowExecutions(workflowId: string) {
  return apiRequest<WorkflowExecution[]>(`/api/workflows/${workflowId}/executions`)
}

/**
 * 取消执行
 */
export async function cancelExecution(executionId: string) {
  return apiRequest<void>(`/api/workflows/executions/${executionId}/cancel`, {
    method: "POST",
  })
}

/**
 * 暂停执行
 */
export async function pauseExecution(executionId: string) {
  return apiRequest<void>(`/api/workflows/executions/${executionId}/pause`, {
    method: "POST",
  })
}

/**
 * 恢复执行
 */
export async function resumeExecution(executionId: string) {
  return apiRequest<void>(`/api/workflows/executions/${executionId}/resume`, {
    method: "POST",
  })
}

/**
 * 重试执行
 */
export async function retryExecution(executionId: string) {
  return apiRequest<WorkflowExecution>(`/api/workflows/executions/${executionId}/retry`, {
    method: "POST",
  })
}

/**
 * 获取执行日志
 */
export async function getExecutionLogs(executionId: string) {
  return apiRequest<string>(`/api/workflows/executions/${executionId}/logs`)
}

/**
 * 获取工作流统计信息
 */
export async function getWorkflowStatistics(workflowId: string) {
  return apiRequest<{
    totalExecutions: number
    successfulExecutions: number
    failedExecutions: number
    runningExecutions: number
    averageDuration: number
  }>(`/api/workflows/${workflowId}/statistics`)
}

// 带 Toast 的版本
export async function getWorkflowsWithToast() {
  try {
    const response = await getWorkflows()
    return response
  } catch (error) {
    throw error
  }
}

export async function createWorkflowWithToast(data: {
  name: string
  description?: string
  definition: string
}) {
  try {
    const response = await createWorkflow(data)
    return response
  } catch (error) {
    throw error
  }
}

export async function updateWorkflowWithToast(workflowId: string, data: Partial<Workflow>) {
  try {
    const response = await updateWorkflow(workflowId, data)
    return response
  } catch (error) {
    throw error
  }
}

export async function deleteWorkflowWithToast(workflowId: string) {
  try {
    const response = await deleteWorkflow(workflowId)
    return response
  } catch (error) {
    throw error
  }
}
