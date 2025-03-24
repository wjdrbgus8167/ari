package com.ccc.ari.global.security;

import com.ccc.ari.global.error.ErrorCode;
import com.ccc.ari.global.util.JsonResponseUtils;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import org.springframework.security.access.AccessDeniedException;
import org.springframework.security.web.access.AccessDeniedHandler;

import java.io.IOException;

public class JwtAccessDeniedHandler implements AccessDeniedHandler {

    @Override
    public void handle(HttpServletRequest request, HttpServletResponse response, AccessDeniedException accessDeniedException) throws IOException, ServletException {
        JsonResponseUtils.sendJsonErrorResponse(request, response, ErrorCode.ACCESS_DENIED);
    }
}