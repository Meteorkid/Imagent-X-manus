import { apiRequest } from "./api"

/**
 * 插件信息接口
 */
export interface PluginInfo {
  id: string
  name: string
  version: string
  description: string
  author: string
  type: string
  status: string
  config: Record<string, any>
  dependencies: string[]
  iconUrl?: string
  homepage?: string
  installedAt?: string
  lastStartedAt?: string
}

/**
 * 获取所有插件
 */
export async function getPlugins() {
  return apiRequest<PluginInfo[]>("/api/plugins")
}

/**
 * 获取插件详情
 */
export async function getPlugin(pluginId: string) {
  return apiRequest<PluginInfo>(`/api/plugins/${pluginId}`)
}

/**
 * 安装插件（从文件）
 */
export async function installPluginFromFile(file: File) {
  const formData = new FormData()
  formData.append("file", file)

  return apiRequest<PluginInfo>("/api/plugins/install/file", {
    method: "POST",
    body: formData,
  })
}

/**
 * 安装插件（从URL）
 */
export async function installPluginFromUrl(url: string) {
  return apiRequest<PluginInfo>("/api/plugins/install/url", {
    method: "POST",
    body: JSON.stringify({ url }),
  })
}

/**
 * 卸载插件
 */
export async function uninstallPlugin(pluginId: string) {
  return apiRequest<void>(`/api/plugins/${pluginId}`, {
    method: "DELETE",
  })
}

/**
 * 启用插件
 */
export async function enablePlugin(pluginId: string) {
  return apiRequest<void>(`/api/plugins/${pluginId}/enable`, {
    method: "POST",
  })
}

/**
 * 禁用插件
 */
export async function disablePlugin(pluginId: string) {
  return apiRequest<void>(`/api/plugins/${pluginId}/disable`, {
    method: "POST",
  })
}

/**
 * 更新插件配置
 */
export async function updatePluginConfig(pluginId: string, config: Record<string, any>) {
  return apiRequest<void>(`/api/plugins/${pluginId}/config`, {
    method: "PUT",
    body: JSON.stringify(config),
  })
}

/**
 * 获取插件配置
 */
export async function getPluginConfig(pluginId: string) {
  return apiRequest<Record<string, any>>(`/api/plugins/${pluginId}/config`)
}

/**
 * 获取插件日志
 */
export async function getPluginLogs(pluginId: string, lines: number = 100) {
  return apiRequest<string[]>(`/api/plugins/${pluginId}/logs?lines=${lines}`)
}

/**
 * 检查插件更新
 */
export async function checkPluginUpdates(pluginId: string) {
  return apiRequest<boolean>(`/api/plugins/${pluginId}/updates`)
}

/**
 * 更新插件
 */
export async function updatePlugin(pluginId: string) {
  return apiRequest<PluginInfo>(`/api/plugins/${pluginId}/update`, {
    method: "POST",
  })
}

/**
 * 获取插件统计信息
 */
export async function getPluginStatistics() {
  return apiRequest<{
    totalPlugins: number
    enabledPlugins: number
    disabledPlugins: number
    errorPlugins: number
    pluginsByType: Record<string, number>
  }>("/api/plugins/statistics")
}

// 带 Toast 的版本
export async function getPluginsWithToast() {
  try {
    const response = await getPlugins()
    return response
  } catch (error) {
    throw error
  }
}

export async function installPluginFromFileWithToast(file: File) {
  try {
    const response = await installPluginFromFile(file)
    return response
  } catch (error) {
    throw error
  }
}

export async function installPluginFromUrlWithToast(url: string) {
  try {
    const response = await installPluginFromUrl(url)
    return response
  } catch (error) {
    throw error
  }
}

export async function uninstallPluginWithToast(pluginId: string) {
  try {
    const response = await uninstallPlugin(pluginId)
    return response
  } catch (error) {
    throw error
  }
}

export async function enablePluginWithToast(pluginId: string) {
  try {
    const response = await enablePlugin(pluginId)
    return response
  } catch (error) {
    throw error
  }
}

export async function disablePluginWithToast(pluginId: string) {
  try {
    const response = await disablePlugin(pluginId)
    return response
  } catch (error) {
    throw error
  }
}
