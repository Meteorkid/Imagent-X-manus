package org.xhy.interfaces.dto;

import java.util.Map;

public class AgentRequest {
    private String prompt;
    private Map<String, Object> config;
    
    public String getPrompt() {
        return prompt;
    }
    
    public void setPrompt(String prompt) {
        this.prompt = prompt;
    }
    
    public Map<String, Object> getConfig() {
        return config;
    }
    
    public void setConfig(Map<String, Object> config) {
        this.config = config;
    }
}
