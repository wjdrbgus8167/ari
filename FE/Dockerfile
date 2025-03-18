# nginx:alpine 이미지를 기반으로 사용합니다.
FROM nginx:alpine

# 기존 기본 웹 콘텐츠를 삭제합니다.
RUN rm -rf /usr/share/nginx/html/*

# 여러분의 release 폴더(예: APK 파일, 안내 페이지 등)를 Nginx 웹 루트로 복사합니다.
COPY release /usr/share/nginx/html

# 사용자 정의 Nginx 설정 파일을 복사합니다.
COPY nginx.conf /etc/nginx/conf.d/default.conf

# HTTP(80)와 HTTPS(443) 포트를 개방합니다.
EXPOSE 80 443

# Nginx를 포그라운드 모드로 실행합니다.
CMD ["nginx", "-g", "daemon off;"]
