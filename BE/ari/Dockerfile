# 실행 스테이지
FROM openjdk:17-alpine
WORKDIR /app

# 빌드된 JAR 파일 복사
COPY build/libs/ari-0.0.1-SNAPSHOT.jar app.jar

# 로그 디렉토리 생성
RUN mkdir -p /app/logs

# 포트 및 실행 명령
EXPOSE 8080
ENTRYPOINT ["java", "-jar", "app.jar"]