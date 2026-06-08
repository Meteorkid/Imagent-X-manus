package org.xhy.domain.plugin;

import org.xhy.domain.plugin.constant.PluginStatus;
import org.xhy.domain.plugin.constant.PluginType;
import org.xhy.domain.plugin.model.PluginInfo;

import java.util.List;
import java.util.Optional;

/**
 * 插件仓库接口
 * 管理插件信息的持久化
 */
public interface PluginRepository {

    /**
     * 保存插件信息
     *
     * @param pluginInfo 插件信息
     */
    void save(PluginInfo pluginInfo);

    /**
     * 根据ID查找插件
     *
     * @param pluginId 插件ID
     * @return 插件信息
     */
    Optional<PluginInfo> findById(String pluginId);

    /**
     * 根据名称查找插件
     *
     * @param name 插件名称
     * @return 插件信息
     */
    Optional<PluginInfo> findByName(String name);

    /**
     * 查找所有插件
     *
     * @return 插件列表
     */
    List<PluginInfo> findAll();

    /**
     * 根据类型查找插件
     *
     * @param type 插件类型
     * @return 插件列表
     */
    List<PluginInfo> findByType(PluginType type);

    /**
     * 根据状态查找插件
     *
     * @param status 插件状态
     * @return 插件列表
     */
    List<PluginInfo> findByStatus(PluginStatus status);

    /**
     * 根据作者查找插件
     *
     * @param author 作者
     * @return 插件列表
     */
    List<PluginInfo> findByAuthor(String author);

    /**
     * 搜索插件
     *
     * @param keyword 关键词
     * @return 插件列表
     */
    List<PluginInfo> search(String keyword);

    /**
     * 删除插件
     *
     * @param pluginId 插件ID
     */
    void deleteById(String pluginId);

    /**
     * 检查插件是否存在
     *
     * @param pluginId 插件ID
     * @return 是否存在
     */
    boolean existsById(String pluginId);

    /**
     * 检查插件名称是否已存在
     *
     * @param name 插件名称
     * @param excludeId 排除的插件ID
     * @return 是否存在
     */
    boolean existsByName(String name, String excludeId);

    /**
     * 获取插件总数
     *
     * @return 插件数量
     */
    long count();

    /**
     * 获取指定状态的插件数量
     *
     * @param status 插件状态
     * @return 插件数量
     */
    long countByStatus(PluginStatus status);
}
