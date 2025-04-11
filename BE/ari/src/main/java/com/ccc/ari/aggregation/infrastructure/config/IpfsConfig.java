package com.ccc.ari.aggregation.infrastructure.config;

import com.ccc.ari.aggregation.domain.client.IpfsClient;
import com.ccc.ari.aggregation.infrastructure.adapter.CachingIpfsClientImpl;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.context.annotation.Primary;
import org.springframework.scheduling.annotation.EnableScheduling;

@Configuration
@EnableScheduling
public class IpfsConfig {

    @Bean
    @Primary
    public IpfsClient ipfsClient(
            @Value("${PINATA_ENDPOINT}") String ipfsApiUrl,
            @Value("${PINATA_JWT}") String jwtToken,
            @Value("${PINATA_GATEWAY}") String gatewayDomain,
            @Value("${IPFS_LOCAL_NODE_URL}") String localNodeUrl,
            @Value("${IPFS_USE_LOCAL_CACHE}") boolean useLocalCache,
            @Value("${IPFS_TIMEOUT:15000}") int timeout) {

        return new CachingIpfsClientImpl(ipfsApiUrl, jwtToken, gatewayDomain, localNodeUrl, useLocalCache, timeout);
    }
}