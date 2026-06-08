package org.xhy.domain.plugin;

import org.xhy.domain.plugin.model.PluginInfo;

import java.nio.file.Path;
import java.util.List;

/**
 * 插件加载器接口
 * 负责加载和解析插件
 */
public interface PluginLoader {

    /**
     * 加载插件
     *
     * @param pluginPath 插件路径
     * @return 插件实例
     */
    Plugin loadPlugin(Path pluginPath);

    /**
     * 卸载插件
     *
     * @param plugin 插件实例
     */
    void unloadPlugin(Plugin plugin);

    /**
     * 加载插件目录中的所有插件
     *
     * @param directory 插件目录
     * @return 插件列表
     */
    List<Plugin> loadPluginsFromDirectory(Path directory);

    /**
     * 验证插件
     *
     * @param pluginPath 插件路径
     * @return 验证结果
     */
    ValidationResult validatePlugin(Path pluginPath);

    /**
     * 获取插件元数据
     *
     * @param pluginPath 插件路径
     * @return 插件信息
     */
    PluginInfo getPluginMetadata(Path pluginPath);

    /**
     * 插件验证结果
     */
    class ValidationResult {
        private final boolean valid;
        private final List<String> errors;
        private final List<String> warnings;

        public ValidationResult(boolean valid, List<String> errors, List<String> warnings) {
            this.valid = valid;
            this.errors = errors;
            this.warnings = warnings;
        }

        public boolean isValid() {
            return valid;
        }

        public List<String> getErrors() {
            return errors;
        }

        public List<String> getWarnings() {
            return warnings;
        }
    }
}
