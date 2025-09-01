package org.xhy.application.service;

import org.xhy.interfaces.dto.AgentRequest;
import org.springframework.stereotype.Service;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import java.io.BufferedReader;
import java.io.InputStreamReader;
import java.io.IOException;
import java.util.concurrent.TimeUnit;

@Service
public class AgentService {
    
    private static final Logger log = LoggerFactory.getLogger(AgentService.class);

    public String runOpenManus(AgentRequest request) throws Exception {
        log.info("开始执行OpenManus请求: {}", request.getPrompt());
        
        // 构建Python命令
        String pythonScript = "OpenManus/main.py";
        String[] command = {
            "python", 
            pythonScript, 
            "--prompt", 
            request.getPrompt()
        };
        
        // 执行命令
        ProcessBuilder processBuilder = new ProcessBuilder(command);
        processBuilder.redirectErrorStream(true);
        
        Process process = processBuilder.start();
        
        // 读取输出
        StringBuilder output = new StringBuilder();
        try (BufferedReader reader = new BufferedReader(
                new InputStreamReader(process.getInputStream()))) {
            String line;
            while ((line = reader.readLine()) != null) {
                output.append(line).append("\n");
            }
        }
        
        // 等待进程完成，设置超时时间
        boolean finished = process.waitFor(60, TimeUnit.SECONDS);
        
        if (!finished) {
            process.destroyForcibly();
            throw new RuntimeException("OpenManus执行超时");
        }
        
        int exitCode = process.exitValue();
        if (exitCode != 0) {
            throw new RuntimeException("OpenManus执行失败，退出码: " + exitCode);
        }
        
        log.info("OpenManus执行完成");
        return output.toString();
    }
    
    public boolean checkOpenManusStatus() {
        try {
            // 检查OpenManus目录是否存在
            String openManusPath = "OpenManus";
            java.io.File openManusDir = new java.io.File(openManusPath);
            
            if (!openManusDir.exists() || !openManusDir.isDirectory()) {
                log.warn("OpenManus目录不存在: {}", openManusPath);
                return false;
            }
            
            // 检查main.py文件是否存在
            java.io.File mainPy = new java.io.File(openManusPath + "/main.py");
            if (!mainPy.exists()) {
                log.warn("OpenManus main.py文件不存在");
                return false;
            }
            
            // 检查Python环境
            ProcessBuilder processBuilder = new ProcessBuilder("python", "--version");
            Process process = processBuilder.start();
            boolean finished = process.waitFor(5, TimeUnit.SECONDS);
            
            if (!finished) {
                process.destroyForcibly();
                return false;
            }
            
            return process.exitValue() == 0;
            
        } catch (Exception e) {
            log.error("检查OpenManus状态失败", e);
            return false;
        }
    }
}
