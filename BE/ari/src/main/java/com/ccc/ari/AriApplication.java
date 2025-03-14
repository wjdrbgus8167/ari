package com.ccc.ari;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.boot.autoconfigure.jdbc.DataSourceAutoConfiguration;


@SpringBootApplication(exclude = {DataSourceAutoConfiguration.class})  // 초기 테스트용 (DB 설정 후 삭제)
//@SpringBootApplication()
public class AriApplication {

	public static void main(String[] args) {
		SpringApplication.run(AriApplication.class, args);
	}

}
