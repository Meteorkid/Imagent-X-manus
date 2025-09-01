-- 将数据库中的agentx（所有大小写形式）替换为Imagent X的完整SQL脚本
-- 执行前请备份数据库
-- 此脚本包含所有相关表的更新操作

-- ========================================
-- 用户相关表更新
-- ========================================

-- 1. 更新用户表中的昵称（处理所有大小写形式）
UPDATE users 
SET nickname = REPLACE(REPLACE(REPLACE(nickname, 'agentx', 'Imagent X'), 'Agentx', 'Imagent X'), 'AGENTX', 'Imagent X')
WHERE nickname ILIKE '%agentx%';

-- 2. 更新用户表中的邮箱（处理所有大小写形式）
UPDATE users 
SET email = REPLACE(REPLACE(REPLACE(email, 'agentx', 'imagentx'), 'Agentx', 'imagentx'), 'AGENTX', 'imagentx')
WHERE email ILIKE '%agentx%';

-- ========================================
-- 代理相关表更新
-- ========================================

-- 3. 更新agents表中的名称（处理所有大小写形式）
UPDATE agents 
SET name = REPLACE(REPLACE(REPLACE(name, 'agentx', 'Imagent X'), 'Agentx', 'Imagent X'), 'AGENTX', 'Imagent X')
WHERE name ILIKE '%agentx%';

-- 4. 更新agents表中的描述（处理所有大小写形式）
UPDATE agents 
SET description = REPLACE(REPLACE(REPLACE(description, 'agentx', 'Imagent X'), 'Agentx', 'Imagent X'), 'AGENTX', 'Imagent X')
WHERE description ILIKE '%agentx%';

-- 5. 更新agents表中的系统提示（处理所有大小写形式）
UPDATE agents 
SET system_prompt = REPLACE(REPLACE(REPLACE(system_prompt, 'agentx', 'Imagent X'), 'Agentx', 'Imagent X'), 'AGENTX', 'Imagent X')
WHERE system_prompt ILIKE '%agentx%';

-- 6. 更新agents表中的欢迎消息（处理所有大小写形式）
UPDATE agents 
SET welcome_message = REPLACE(REPLACE(REPLACE(welcome_message, 'agentx', 'Imagent X'), 'Agentx', 'Imagent X'), 'AGENTX', 'Imagent X')
WHERE welcome_message ILIKE '%agentx%';

-- ========================================
-- 消息相关表更新
-- ========================================

-- 7. 更新messages表中的内容（处理所有大小写形式）
UPDATE messages 
SET content = REPLACE(REPLACE(REPLACE(content, 'agentx', 'Imagent X'), 'Agentx', 'Imagent X'), 'AGENTX', 'Imagent X')
WHERE content ILIKE '%agentx%';

-- 8. 更新messages表中的角色（处理所有大小写形式）
UPDATE messages 
SET role = REPLACE(REPLACE(REPLACE(role, 'agentx', 'Imagent X'), 'Agentx', 'Imagent X'), 'AGENTX', 'Imagent X')
WHERE role ILIKE '%agentx%';

-- ========================================
-- 工具相关表更新
-- ========================================

-- 9. 更新tools表中的名称（处理所有大小写形式）
UPDATE tools 
SET name = REPLACE(REPLACE(REPLACE(name, 'agentx', 'Imagent X'), 'Agentx', 'Imagent X'), 'AGENTX', 'Imagent X')
WHERE name ILIKE '%agentx%';

-- 10. 更新tools表中的描述（处理所有大小写形式）
UPDATE tools 
SET description = REPLACE(REPLACE(REPLACE(description, 'agentx', 'Imagent X'), 'Agentx', 'Imagent X'), 'AGENTX', 'Imagent X')
WHERE description ILIKE '%agentx%';

-- ========================================
-- 服务提供商相关表更新
-- ========================================

-- 11. 更新providers表中的名称（处理所有大小写形式）
UPDATE providers 
SET name = REPLACE(REPLACE(REPLACE(name, 'agentx', 'Imagent X'), 'Agentx', 'Imagent X'), 'AGENTX', 'Imagent X')
WHERE name ILIKE '%agentx%';

-- 12. 更新providers表中的描述（处理所有大小写形式）
UPDATE providers 
SET description = REPLACE(REPLACE(REPLACE(description, 'agentx', 'Imagent X'), 'Agentx', 'Imagent X'), 'AGENTX', 'Imagent X')
WHERE description ILIKE '%agentx%';

-- ========================================
-- 模型相关表更新
-- ========================================

-- 13. 更新models表中的名称（处理所有大小写形式）
UPDATE models 
SET name = REPLACE(REPLACE(REPLACE(name, 'agentx', 'Imagent X'), 'Agentx', 'Imagent X'), 'AGENTX', 'Imagent X')
WHERE name ILIKE '%agentx%';

-- 14. 更新models表中的描述（处理所有大小写形式）
UPDATE models 
SET description = REPLACE(REPLACE(REPLACE(description, 'agentx', 'Imagent X'), 'Agentx', 'Imagent X'), 'AGENTX', 'Imagent X')
WHERE description ILIKE '%agentx%';

-- ========================================
-- 产品相关表更新
-- ========================================

-- 15. 更新products表中的名称（处理所有大小写形式）
UPDATE products 
SET name = REPLACE(REPLACE(REPLACE(name, 'agentx', 'Imagent X'), 'Agentx', 'Imagent X'), 'AGENTX', 'Imagent X')
WHERE name ILIKE '%agentx%';

-- ========================================
-- 规则相关表更新
-- ========================================

-- 16. 更新rules表中的名称（处理所有大小写形式）
UPDATE rules 
SET name = REPLACE(REPLACE(REPLACE(name, 'agentx', 'Imagent X'), 'Agentx', 'Imagent X'), 'AGENTX', 'Imagent X')
WHERE name ILIKE '%agentx%';

-- 17. 更新rules表中的描述（处理所有大小写形式）
UPDATE rules 
SET description = REPLACE(REPLACE(REPLACE(description, 'agentx', 'Imagent X'), 'Agentx', 'Imagent X'), 'AGENTX', 'Imagent X')
WHERE description ILIKE '%agentx%';

-- ========================================
-- 上下文相关表更新
-- ========================================

-- 18. 更新context表中的摘要（处理所有大小写形式）
UPDATE context 
SET summary = REPLACE(REPLACE(REPLACE(summary, 'agentx', 'Imagent X'), 'Agentx', 'Imagent X'), 'AGENTX', 'Imagent X')
WHERE summary ILIKE '%agentx%';

-- ========================================
-- 文档相关表更新
-- ========================================

-- 19. 更新document_unit表中的内容（处理所有大小写形式）
UPDATE document_unit 
SET content = REPLACE(REPLACE(REPLACE(content, 'agentx', 'Imagent X'), 'Agentx', 'Imagent X'), 'AGENTX', 'Imagent X')
WHERE content ILIKE '%agentx%';

-- ========================================
-- 文件相关表更新
-- ========================================

-- 20. 更新file_detail表中的文件名（处理所有大小写形式）
UPDATE file_detail 
SET filename = REPLACE(REPLACE(REPLACE(filename, 'agentx', 'Imagent X'), 'Agentx', 'Imagent X'), 'AGENTX', 'Imagent X')
WHERE filename ILIKE '%agentx%';

-- 21. 更新file_detail表中的原始文件名（处理所有大小写形式）
UPDATE file_detail 
SET original_filename = REPLACE(REPLACE(REPLACE(original_filename, 'agentx', 'Imagent X'), 'Agentx', 'Imagent X'), 'AGENTX', 'Imagent X')
WHERE original_filename ILIKE '%agentx%';

-- ========================================
-- 更新结果统计
-- ========================================

-- 显示更新结果统计
SELECT 'users' as table_name, COUNT(*) as updated_count FROM users WHERE nickname ILIKE '%Imagent X%' OR email ILIKE '%imagentx%'
UNION ALL
SELECT 'agents' as table_name, COUNT(*) as updated_count FROM agents WHERE name ILIKE '%Imagent X%' OR description ILIKE '%Imagent X%'
UNION ALL
SELECT 'messages' as table_name, COUNT(*) as updated_count FROM messages WHERE content ILIKE '%Imagent X%' OR role ILIKE '%Imagent X%'
UNION ALL
SELECT 'tools' as table_name, COUNT(*) as updated_count FROM tools WHERE name ILIKE '%Imagent X%' OR description ILIKE '%Imagent X%'
UNION ALL
SELECT 'providers' as table_name, COUNT(*) as updated_count FROM providers WHERE name ILIKE '%Imagent X%' OR description ILIKE '%Imagent X%'
UNION ALL
SELECT 'models' as table_name, COUNT(*) as updated_count FROM models WHERE name ILIKE '%Imagent X%' OR description ILIKE '%Imagent X%'
UNION ALL
SELECT 'products' as table_name, COUNT(*) as updated_count FROM products WHERE name ILIKE '%Imagent X%'
UNION ALL
SELECT 'rules' as table_name, COUNT(*) as updated_count FROM rules WHERE name ILIKE '%Imagent X%' OR description ILIKE '%Imagent X%'
UNION ALL
SELECT 'context' as table_name, COUNT(*) as updated_count FROM context WHERE summary ILIKE '%Imagent X%'
UNION ALL
SELECT 'document_unit' as table_name, COUNT(*) as updated_count FROM document_unit WHERE content ILIKE '%Imagent X%'
UNION ALL
SELECT 'file_detail' as table_name, COUNT(*) as updated_count FROM file_detail WHERE filename ILIKE '%Imagent X%' OR original_filename ILIKE '%Imagent X%';

-- ========================================
-- 使用说明
-- ========================================
-- 
-- 执行此脚本前请确保：
-- 1. 已备份数据库
-- 2. 应用服务已停止
-- 3. 有足够的权限执行更新操作
--
-- 执行命令：
-- docker exec -i agentx-app psql -U agentx_user -d agentx < update_agentx_to_imagentx.sql
--
-- 注意：此脚本会将所有包含"agentx"、"Agentx"、"AGENTX"的内容替换为"Imagent X"
-- 邮箱地址中的"agentx"、"Agentx"、"AGENTX"会被替换为"imagentx"（小写）
