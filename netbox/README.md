# Hướng dẫn sử dụng docker compose để cấu hình netbox + nginx làm revser proxy
Tài liệu để build netbox riêng lẻ được tôi sử dụng và tham khảo [ở đây](https://github.com/netbox-community/netbox-docker). Điều tôi làm chỉ là tận dụng cấu hình của họ và sửa lại để cho phù hợp với mục đích của mình

## 1. Mô hình docker compose mà tôi build

![alt text](../anh/Screenshot_39.png)

Giải thích:
- 4 container này được sử dụng chung 1 docker network (netbox_net)
- Chỉ có duy nhất container my_nginx được ánh xạ 2 port 80 <-> 80, 443 <-> 443

## 2. Hướng dẫn sử dụng 
- Đầu tiên bạn sẽ cần download repo này về 
  ```
  cd /opt/
  git clone https://github.com/thanhquang99/Docker
  ```
- Tiếp theo ta sẽ chạy file docker compose
  ```
  cd /opt/Docker/netbox/
  docker compose up
  ```
  ![alt text](../anh/Screenshot_41.png)
  - Ta có thể tùy chỉnh biến trong file docker compose để thay đổi user và password của netbox hay postgres
  ```
  vi /opt/Docker/netbox/docker-compose.yml
  ```
  ![alt text](../anh/Screenshot_40.png)
- Đợi thời gian khoảng 5 phút để docker compose chạy xong ta sẽ tạo thêm 1 terminal mới `ctrl +shirt +u` để tiến hành active bao gòm tạo super user và cấu hình nginx làm reverse proxy