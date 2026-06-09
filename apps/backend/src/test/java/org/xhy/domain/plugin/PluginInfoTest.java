package org.xhy.domain.plugin;

import org.junit.jupiter.api.Test;
import org.xhy.domain.plugin.constant.PluginStatus;
import org.xhy.domain.plugin.constant.PluginType;
import org.xhy.domain.plugin.model.PluginInfo;

import java.time.LocalDateTime;
import java.util.HashMap;
import java.util.Map;

import static org.junit.jupiter.api.Assertions.*;

class PluginInfoTest {

    @Test
    void pluginInfo_ShouldCreateWithRequiredFields() {
        // Arrange & Act
        PluginInfo pluginInfo = new PluginInfo();
        pluginInfo.setId("test-plugin");
        pluginInfo.setName("Test Plugin");
        pluginInfo.setVersion("1.0.0");
        pluginInfo.setType(PluginType.EXTENSION);
        pluginInfo.setStatus(PluginStatus.INSTALLED);

        // Assert
        assertEquals("test-plugin", pluginInfo.getId());
        assertEquals("Test Plugin", pluginInfo.getName());
        assertEquals("1.0.0", pluginInfo.getVersion());
        assertEquals(PluginType.EXTENSION, pluginInfo.getType());
        assertEquals(PluginStatus.INSTALLED, pluginInfo.getStatus());
    }

    @Test
    void pluginInfo_ShouldSupportConfig() {
        // Arrange
        PluginInfo pluginInfo = new PluginInfo();
        Map<String, Object> config = new HashMap<>();
        config.put("key1", "value1");
        config.put("key2", 123);

        // Act
        pluginInfo.setConfig(config);

        // Assert
        assertNotNull(pluginInfo.getConfig());
        assertEquals("value1", pluginInfo.getConfig().get("key1"));
        assertEquals(123, pluginInfo.getConfig().get("key2"));
    }

    @Test
    void pluginInfo_ShouldSupportDependencies() {
        // Arrange
        PluginInfo pluginInfo = new PluginInfo();
        String[] dependencies = {"dep1", "dep2"};

        // Act
        pluginInfo.setDependencies(dependencies);

        // Assert
        assertNotNull(pluginInfo.getDependencies());
        assertEquals(2, pluginInfo.getDependencies().length);
        assertEquals("dep1", pluginInfo.getDependencies()[0]);
    }

    @Test
    void pluginInfo_ShouldTrackTimestamps() {
        // Arrange
        PluginInfo pluginInfo = new PluginInfo();
        LocalDateTime now = LocalDateTime.now();

        // Act
        pluginInfo.setCreatedAt(now);
        pluginInfo.setUpdatedAt(now);
        pluginInfo.setInstalledAt(now);

        // Assert
        assertEquals(now, pluginInfo.getCreatedAt());
        assertEquals(now, pluginInfo.getUpdatedAt());
        assertEquals(now, pluginInfo.getInstalledAt());
    }
}
