#!/usr/bin/env bash
set -u

ROOT_DIR="$(cd "$(dirname "$0")/../.." && pwd)"
ENV_FILE="${1:-$ROOT_DIR/scripts/testing/langchain4j-smoke.env}"
REPORT_DIR="$ROOT_DIR/reports/smoke"
TIMESTAMP="$(date +"%Y%m%d-%H%M%S")"
REPORT_FILE="$REPORT_DIR/langchain4j-smoke-$TIMESTAMP.md"

mkdir -p "$REPORT_DIR"

if [ -f "$ENV_FILE" ]; then
  # shellcheck source=/dev/null
  source "$ENV_FILE"
fi

PASS_COUNT=0
FAIL_COUNT=0
SKIP_COUNT=0

append() {
  printf "%s\n" "$1" >> "$REPORT_FILE"
}

run_required() {
  local title="$1"
  local cmd="$2"
  local tmp
  tmp="$(mktemp)"

  append "## $title"
  append ""
  append "- 命令: \`$cmd\`"

  if bash -lc "$cmd" >"$tmp" 2>&1; then
    PASS_COUNT=$((PASS_COUNT + 1))
    append "- 结果: ✅ 通过"
  else
    FAIL_COUNT=$((FAIL_COUNT + 1))
    append "- 结果: ❌ 失败"
  fi

  append ""
  append '```text'
  sed -n '1,80p' "$tmp" >> "$REPORT_FILE"
  append '```'
  append ""
  rm -f "$tmp"
}

run_optional() {
  local title="$1"
  local condition="$2"
  local cmd="$3"
  local tmp
  tmp="$(mktemp)"

  append "## $title"
  append ""

  if ! bash -lc "$condition" >/dev/null 2>&1; then
    SKIP_COUNT=$((SKIP_COUNT + 1))
    append "- 结果: ⏭️ 跳过（未提供必需环境变量）"
    append ""
    rm -f "$tmp"
    return
  fi

  append "- 命令: \`$cmd\`"
  if bash -lc "$cmd" >"$tmp" 2>&1; then
    PASS_COUNT=$((PASS_COUNT + 1))
    append "- 结果: ✅ 通过"
  else
    FAIL_COUNT=$((FAIL_COUNT + 1))
    append "- 结果: ❌ 失败"
  fi
  append ""
  append '```text'
  sed -n '1,80p' "$tmp" >> "$REPORT_FILE"
  append '```'
  append ""
  rm -f "$tmp"
}

run_optional_mcp_gateway_health() {
  local title="MCP 网关健康检查"
  local tmp
  local base_url
  local api_key
  local allow_401
  local endpoint
  local target_url=""
  local status_code=""
  tmp="$(mktemp)"

  base_url="${MCP_GATEWAY_BASE_URL:-}"
  api_key="${MCP_GATEWAY_API_KEY:-}"
  allow_401="${MCP_GATEWAY_ALLOW_401_AS_HEALTHY:-true}"

  append "## $title"
  append ""

  if [ -z "$base_url" ]; then
    SKIP_COUNT=$((SKIP_COUNT + 1))
    append "- 结果: ⏭️ 跳过（未提供必需环境变量）"
    append ""
    rm -f "$tmp"
    return
  fi

  # 兼容用户是否在末尾加 '/'
  base_url="${base_url%/}"
  append "- 命令: \`curl MCP health endpoint(s)\`"

  for endpoint in "/health" "/api/health"; do
    target_url="${base_url}${endpoint}"
    if [ -n "$api_key" ]; then
      status_code="$(curl -sS -o "$tmp" -w "%{http_code}" -H "Authorization: Bearer $api_key" "$target_url" || true)"
    else
      status_code="$(curl -sS -o "$tmp" -w "%{http_code}" "$target_url" || true)"
    fi

    if [ "$status_code" = "200" ]; then
      PASS_COUNT=$((PASS_COUNT + 1))
      append "- 结果: ✅ 通过"
      append "- 说明: endpoint=${target_url} status=200"
      append ""
      append '```text'
      sed -n '1,80p' "$tmp" >> "$REPORT_FILE"
      append '```'
      append ""
      rm -f "$tmp"
      return
    fi

    if [ "$status_code" = "401" ] && [ "$allow_401" != "false" ]; then
      PASS_COUNT=$((PASS_COUNT + 1))
      append "- 结果: ✅ 通过"
      append "- 说明: endpoint=${target_url} status=401（鉴权开启，判定服务可达）"
      append ""
      append '```text'
      if [ -s "$tmp" ]; then
        sed -n '1,80p' "$tmp" >> "$REPORT_FILE"
      else
        printf "%s\n" "HTTP 401 Unauthorized" >> "$REPORT_FILE"
      fi
      append '```'
      append ""
      rm -f "$tmp"
      return
    fi
  done

  FAIL_COUNT=$((FAIL_COUNT + 1))
  append "- 结果: ❌ 失败"
  append "- 说明: endpoints=${base_url}/health,${base_url}/api/health (最后状态码=${status_code:-n/a})"
  append ""
  append '```text'
  if [ -s "$tmp" ]; then
    sed -n '1,80p' "$tmp" >> "$REPORT_FILE"
  else
    printf "%s\n" "MCP gateway health check failed without response body." >> "$REPORT_FILE"
  fi
  append '```'
  append ""
  rm -f "$tmp"
}

append "# LangChain4j 灰度报告"
append ""
append "- 时间: $(date '+%Y-%m-%d %H:%M:%S')"
append "- 仓库: $ROOT_DIR"
append "- 环境文件: $ENV_FILE"
append ""

run_required \
  "上游坐标守卫检查" \
  "cd \"$ROOT_DIR\" && ./scripts/testing/check-langchain4j-upstream.sh"

run_required \
  "后端编译检查" \
  "cd \"$ROOT_DIR/apps/backend\" && mvn -q -DskipTests compile"

run_required \
  "LangChain4j 兼容测试套件" \
  "cd \"$ROOT_DIR/apps/backend\" && mvn test -q -Dtest=LangChain4jCompatibilityTest,HealthControllerWebMvcTest,MCPGatewayServiceTest,TraceContextFilterTest"

run_optional \
  "后端健康检查" \
  "[ -n \"\${BACKEND_HEALTH_URL:-}\" ]" \
  "curl -fsS \"${BACKEND_HEALTH_URL:-}\""

run_optional \
  "OpenAI 真实调用冒烟" \
  "[ -n \"\${OPENAI_API_KEY:-}\" ] && [ -n \"\${OPENAI_MODEL:-}\" ]" \
  "curl -fsS -X POST \"${OPENAI_BASE_URL:-https://api.openai.com/v1}/chat/completions\" -H \"Authorization: Bearer ${OPENAI_API_KEY:-}\" -H \"Content-Type: application/json\" -d '{\"model\":\"${OPENAI_MODEL:-gpt-4o-mini}\",\"messages\":[{\"role\":\"user\",\"content\":\"reply ok\"}],\"max_tokens\":5}'"

run_optional \
  "Anthropic 真实调用冒烟" \
  "[ -n \"\${ANTHROPIC_API_KEY:-}\" ] && [ -n \"\${ANTHROPIC_MODEL:-}\" ]" \
  "curl -fsS -X POST \"${ANTHROPIC_BASE_URL:-https://api.anthropic.com}/v1/messages\" -H \"x-api-key: ${ANTHROPIC_API_KEY:-}\" -H \"anthropic-version: 2023-06-01\" -H \"content-type: application/json\" -d '{\"model\":\"${ANTHROPIC_MODEL:-claude-3-5-haiku-latest}\",\"max_tokens\":16,\"messages\":[{\"role\":\"user\",\"content\":\"reply ok\"}]}'"

run_optional_mcp_gateway_health

run_optional \
  "PostgreSQL + pgvector 检查" \
  "command -v psql >/dev/null 2>&1 && [ -n \"\${PGHOST:-}\" ] && [ -n \"\${PGDATABASE:-}\" ] && [ -n \"\${PGUSER:-}\" ] && [ -n \"\${PGPASSWORD:-}\" ]" \
  "PGPASSWORD=\"${PGPASSWORD:-}\" psql -h \"${PGHOST:-}\" -p \"${PGPORT:-5432}\" -U \"${PGUSER:-}\" -d \"${PGDATABASE:-}\" -c \"select extname from pg_extension where extname = 'vector';\""

append "---"
append ""
append "## 汇总"
append ""
append "- ✅ 通过: $PASS_COUNT"
append "- ❌ 失败: $FAIL_COUNT"
append "- ⏭️ 跳过: $SKIP_COUNT"
append ""

echo "灰度报告已生成: $REPORT_FILE"
echo "通过=$PASS_COUNT 失败=$FAIL_COUNT 跳过=$SKIP_COUNT"

if [ "$FAIL_COUNT" -gt 0 ]; then
  exit 1
fi
