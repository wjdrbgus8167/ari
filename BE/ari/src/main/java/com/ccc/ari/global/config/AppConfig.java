package com.ccc.ari.global.config;

import org.springframework.beans.factory.annotation.Value;
import org.springframework.context.annotation.Configuration;

@Configuration
public class AppConfig {

    @Value("${REDIS_HOST}")
    private String domain;

    public String getDomain() {
        return domain;
    }
}
