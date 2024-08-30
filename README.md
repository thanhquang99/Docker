# Thổng hợp những tìm hiểu về docker của mình
## 1. [Lý thuyết ban đầu khi mình chưa biết gì về docker](https://github.com/thanhquang99/Docker/tree/main/l%C3%BD%20thuy%E1%BA%BFt)

Trong phần này sẽ ghi chép quá trình khi mình không biết gì về docker đến mức cơ bản

Ở trong phần này sẽ bao gồm lý thuyết cở bản của docker như:
- Cách IP table hoạt động
- Cấu trúc volume của docker
- Cấu trúc network của docekr
- Cách thành phần của docker như: docker compose, docker file,...
- ...

## 2. [Xây dựng netbox trên docker](https://github.com/thanhquang99/Docker/tree/main/netbox)

Đây là phần mình tự build được netbox trên docker và tùy chỉnh nó để sử dụng cho mình

Ở phần này sẽ bao gồm:
- Viết docker file để tùy chỉnh lại image docker của netbox
- Docker compose để build lên 4 container: netbox, postgres, redis, nginx
- file active để cấu hình superuser, nginx reveser proxy

