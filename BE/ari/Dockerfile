# 빌드 스테이지
FROM gradle:8.12-jdk17 AS builder
WORKDIR /build

# Gradle 파일 복사 및 의존성 캐싱
COPY build.gradle settings.gradle /build/
RUN gradle build -x test --parallel --continue > /dev/null 2>&1 || true

# 전체 프로젝트 복사 후 빌드
COPY . /build
RUN gradle clean build -x test --parallel

# 실행 스테이지
FROM openjdk:17-alpine
WORKDIR /app

# 빌드된 JAR 파일 복사
COPY --from=builder /build/build/libs/ari-0.0.1-SNAPSHOT.jar app.jar

# 로그 디렉토리 생성
RUN mkdir -p /app/logs

# 포트 및 실행 명령
EXPOSE 8080
ENTRYPOINT ["java", "-jar", "app.jar"]