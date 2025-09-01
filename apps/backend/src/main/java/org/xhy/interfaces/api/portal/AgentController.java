package org.xhy.interfaces.api.portal;

import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import org.xhy.interfaces.dto.AgentRequest;
import org.xhy.interfaces.dto.AgentResponse;
import org.xhy.application.service.AgentService;
import org.springframework.beans.factory.annotation.Autowired;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

@RestController
@RequestMapping("/api/agents")
public class AgentController {
    
    private static final Logger log = LoggerFactory.getLogger(AgentController.class);

    @Autowired
    private AgentService agentService;

    @PostMapping("/openmanus")
    public ResponseEntity<AgentResponse> runOpenManus(@RequestBody AgentRequest request) {
        try {
            log.info("收到OpenManus请求: {}", request.getPrompt());
            
            String response = agentService.runOpenManus(request);
            
            AgentResponse agentResponse = new AgentResponse();
            agentResponse.setSuccess(true);
            agentResponse.setResponse(response);
            agentResponse.setMessage("智能体执行成功");
            
            return ResponseEntity.ok(agentResponse);
        } catch (Exception e) {
            log.error("OpenManus执行失败", e);
            
            AgentResponse errorResponse = new AgentResponse();
            errorResponse.setSuccess(false);
            errorResponse.setMessage("智能体执行失败: " + e.getMessage());
            
            return ResponseEntity.status(500).body(errorResponse);
        }
    }

    @GetMapping("/status")
    public ResponseEntity<AgentResponse> getStatus() {
        try {
            boolean isAvailable = agentService.checkOpenManusStatus();
            
            AgentResponse response = new AgentResponse();
            response.setSuccess(isAvailable);
            response.setMessage(isAvailable ? "OpenManus服务正常" : "OpenManus服务不可用");
            
            return ResponseEntity.ok(response);
        } catch (Exception e) {
            log.error("检查OpenManus状态失败", e);
            
            AgentResponse errorResponse = new AgentResponse();
            errorResponse.setSuccess(false);
            errorResponse.setMessage("检查服务状态失败");
            
            return ResponseEntity.status(500).body(errorResponse);
        }
    }
}
