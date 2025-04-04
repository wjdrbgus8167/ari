package com.ccc.ari.global.config;

import com.ccc.ari.aggregation.domain.vo.StreamingLog;
import com.ccc.ari.chart.domain.entity.Chart;
import com.ccc.ari.chart.domain.entity.StreamingWindow;
import com.ccc.ari.exhibition.domain.entity.*;
import com.fasterxml.jackson.annotation.JsonTypeInfo;
import com.fasterxml.jackson.databind.ObjectMapper;
import com.fasterxml.jackson.databind.SerializationFeature;
import com.fasterxml.jackson.databind.jsontype.impl.LaissezFaireSubTypeValidator;
import com.fasterxml.jackson.datatype.jsr310.JavaTimeModule;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.data.redis.connection.RedisConnectionFactory;
import org.springframework.data.redis.connection.RedisStandaloneConfiguration;
import org.springframework.data.redis.connection.lettuce.LettuceConnectionFactory;
import org.springframework.data.redis.core.RedisTemplate;
import org.springframework.data.redis.repository.configuration.EnableRedisRepositories;
import org.springframework.data.redis.serializer.GenericJackson2JsonRedisSerializer;
import org.springframework.data.redis.serializer.StringRedisSerializer;

import java.util.Map;

@Configuration
@EnableRedisRepositories
public class RedisConfig {

    @Value("${REDIS_HOST}")
    private String redisHost;

    @Value("${REDIS_PASSWORD}")
    private String redisPassword;

    private int redisPort = 6379;

    @Bean
    public RedisConnectionFactory redisConnectionFactory() {
        RedisStandaloneConfiguration redisConfig = new RedisStandaloneConfiguration(redisHost, redisPort);
        redisConfig.setPassword(redisPassword);
        return new LettuceConnectionFactory(redisConfig);
    }

    @Bean
    public RedisTemplate<String, StreamingLog> redisTemplate() {
        RedisTemplate<String, StreamingLog> template = new RedisTemplate<>();
        template.setConnectionFactory(redisConnectionFactory());
        template.setKeySerializer(new StringRedisSerializer());

        // ObjectMapper 설정
        ObjectMapper objectMapper = new ObjectMapper();
        objectMapper.registerModule(new JavaTimeModule());
        // 타입 정보를 JSON에 포함시키기 위한 default typing 활성화
        objectMapper.activateDefaultTyping(
                LaissezFaireSubTypeValidator.instance,
                ObjectMapper.DefaultTyping.NON_FINAL,
                JsonTypeInfo.As.PROPERTY
        );

        // GenericJackson2JsonRedisSerializer 사용 (권장되는 방식)
        GenericJackson2JsonRedisSerializer jsonSerializer =
                new GenericJackson2JsonRedisSerializer(objectMapper);

        template.setValueSerializer(jsonSerializer);
        template.setHashValueSerializer(jsonSerializer);
        return template;
    }

    @Bean
    public RedisTemplate<String, Chart> chartRedisTemplate() {
        RedisTemplate<String, Chart> template = new RedisTemplate<>();
        configureRedisTemplate(template);
        return template;
    }

    @Bean
    public RedisTemplate<String, Map<String, StreamingWindow>> windowRedisTemplate() {
        RedisTemplate<String, Map<String, StreamingWindow>> template = new RedisTemplate<>();
        configureRedisTemplate(template);
        return template;
    }

    @Bean
    public RedisTemplate<String, Map<String, TrackStreamingWindow>> trackWindowRedisTemplate() {
        RedisTemplate<String, Map<String, TrackStreamingWindow>> template = new RedisTemplate<>();
        configureRedisTemplate(template);
        return template;
    }

    @Bean
    public RedisTemplate<String, PopularTrack> trackRedisTemplate() {
        RedisTemplate<String, PopularTrack> template = new RedisTemplate<>();
        configureRedisTemplate(template);
        return template;
    }

    @Bean
    public RedisTemplate<String, PopularAlbum> albumRedisTemplate() {
        RedisTemplate<String, PopularAlbum> template = new RedisTemplate<>();
        configureRedisTemplate(template);
        return template;
    }

    @Bean
    public RedisTemplate<String, PopularPlaylist> playlistRedisTemplate() {
        RedisTemplate<String, PopularPlaylist> template = new RedisTemplate<>();
        configureRedisTemplate(template);
        return template;
    }

    @Bean
    public RedisTemplate<String, NewAlbum> newAlbumRedisTemplate() {
        RedisTemplate<String, NewAlbum> template = new RedisTemplate<>();
        configureRedisTemplate(template);
        return template;
    }

    // 공통 ObjectMapper 생성 메서드
    private ObjectMapper createCommonObjectMapper() {
        ObjectMapper objectMapper = new ObjectMapper();
        objectMapper.registerModule(new JavaTimeModule());
        objectMapper.disable(SerializationFeature.WRITE_DATES_AS_TIMESTAMPS);
        objectMapper.activateDefaultTyping(
                LaissezFaireSubTypeValidator.instance,
                ObjectMapper.DefaultTyping.NON_FINAL,
                JsonTypeInfo.As.PROPERTY
        );
        return objectMapper;
    }

    // 공통 RedisTemplate 설정 메서드
    private <T> void configureRedisTemplate(RedisTemplate<String, T> template) {
        template.setConnectionFactory(redisConnectionFactory());
        template.setKeySerializer(new StringRedisSerializer());

        GenericJackson2JsonRedisSerializer jsonSerializer =
                new GenericJackson2JsonRedisSerializer(createCommonObjectMapper());

        template.setValueSerializer(jsonSerializer);
        template.setHashKeySerializer(new StringRedisSerializer());
        template.setHashValueSerializer(jsonSerializer);

        template.afterPropertiesSet();
    }
}
