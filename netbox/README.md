# Hướng dẫn sử dụng docker compose để cấu hình netbox + nginx làm revser proxy
Tài liệu để build netbox riêng lẻ được tôi sử dụng và tham khảo [ở đây](https://github.com/netbox-community/netbox-docker). Điều tôi làm chỉ là tận dụng cấu hình của họ và sửa lại để cho phù hợp với mục đích của mình

Phiên bản docker mình sử dụng là Docker ce version 27.2.1
## 1. Mô hình docker compose mà tôi build

![alt text](../anh/Screenshot_39.png)

Giải thích:
- 4 container này được sử dụng chung 1 docker network (netbox_net)
- Chỉ có duy nhất container my_nginx được ánh xạ 2 port 80 <-> 80, 443 <-> 443

## 2. Hướng dẫn sử dụng 
- Đầu tiên bạn sẽ cần download repo này về. Lưu ý bắt buộc phải di chuyển đến thư mục /opt nếu không file active sẽ có thể bị lỗi
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
  ```
  cd /opt/Docker/netbox/
  chmod +x active.sh
  . active.sh
  ```
- Bây giờ ta cần nhập thông tin từ màn hình vào (yêu cầu đúng cú pháp được gợi ý), thông tin sẽ bao gồm tên miền của netbox, gmail, user và password của netbox
  ![alt text](../anh/Screenshot_42.png)
  - Nếu bạn quên thông tin mà bạn đã nhập bạn có thể xem file thông tin
    ```
    root@Quang-docker:~# cat thongtin.txt
    Sửa file hosts thành 172.16.66.41 quang.netbox.com
    Link truy cập netbox: https://quang.netbox.com
    Netbox User: admin
    Netbox password: fdjhuixtyy5dpasfn
    netbox mail: quang@gmail.com
    Sửa file hosts thành 172.16.66.41 quang.netbox.com
    Link truy cập netbox: https://quang.netbox.com
    Netbox User: fdjhuixtyy5dpasfn
    Netbox password: fdjhuixtyy5dpasfn
    netbox mail: quang@gmail.com
    ```