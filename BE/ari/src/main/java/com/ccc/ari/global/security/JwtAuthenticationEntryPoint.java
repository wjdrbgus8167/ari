package com.ccc.ari.global.security;

import com.ccc.ari.global.error.ErrorCode;
import com.ccc.ari.global.util.JsonResponseUtils;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import org.springframework.security.core.AuthenticationException;
import org.springframework.security.web.AuthenticationEntryPoint;

import java.io.IOException;

public class JwtAuthenticationEntryPoint implements AuthenticationEntryPoint {
    @Override
    public void commence(HttpServletRequest request, HttpServletResponse response, AuthenticationException authException) throws IOException {
        if (request.getAttribute("expiredTokenException") != null) {
            JsonResponseUtils.sendJsonErrorResponse(request, response, ErrorCode.EXPIRED_TOKEN);
        }
        else if(request.getAttribute("invalidTokenException") != null){
            JsonResponseUtils.sendJsonErrorResponse(request, response, ErrorCode.INVALID_TOKEN);
        }else{
            JsonResponseUtils.sendJsonErrorResponse(request, response, ErrorCode.AUTHENTICATION_FAILED);
        }

        response.getWriter().flush();
    }
}
