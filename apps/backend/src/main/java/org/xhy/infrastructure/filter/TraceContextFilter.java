package org.xhy.infrastructure.filter;

import jakarta.servlet.FilterChain;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.util.UUID;
import org.slf4j.MDC;
import org.springframework.http.HttpHeaders;
import org.springframework.stereotype.Component;
import org.springframework.util.StringUtils;
import org.springframework.web.filter.OncePerRequestFilter;

/**
 * 为每个请求补齐 trace 信息，便于统一审计 API Key 与浏览器会话两条链路。
 */
@Component
public class TraceContextFilter extends OncePerRequestFilter {

    private static final String REQUEST_ID_HEADER = "X-Request-Id";
    private static final String AUTH_CHANNEL_HEADER = "X-Auth-Channel";
    private static final String IDEMPOTENCY_KEY_HEADER = "X-Idempotency-Key";

    @Override
    protected void doFilterInternal(
            HttpServletRequest request, HttpServletResponse response, FilterChain filterChain)
            throws ServletException, IOException {
        String requestId = request.getHeader(REQUEST_ID_HEADER);
        if (!StringUtils.hasText(requestId)) {
            requestId = UUID.randomUUID().toString();
        }
        String authChannel = resolveAuthChannel(request);
        String idempotencyKey = request.getHeader(IDEMPOTENCY_KEY_HEADER);

        MDC.put("traceId", requestId);
        MDC.put("authChannel", authChannel);
        if (StringUtils.hasText(idempotencyKey)) {
            MDC.put("idempotencyKey", idempotencyKey);
            response.setHeader(IDEMPOTENCY_KEY_HEADER, idempotencyKey);
        }
        response.setHeader(REQUEST_ID_HEADER, requestId);

        try {
            filterChain.doFilter(request, response);
        } finally {
            MDC.remove("traceId");
            MDC.remove("authChannel");
            MDC.remove("idempotencyKey");
        }
    }

    private String resolveAuthChannel(HttpServletRequest request) {
        String headerChannel = request.getHeader(AUTH_CHANNEL_HEADER);
        if (StringUtils.hasText(headerChannel)) {
            return headerChannel;
        }
        String auth = request.getHeader(HttpHeaders.AUTHORIZATION);
        if (StringUtils.hasText(auth)) {
            return "authorization-header";
        }
        if (StringUtils.hasText(request.getHeader(HttpHeaders.COOKIE))) {
            return "cookie-session";
        }
        return "anonymous";
    }
}
