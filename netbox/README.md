- [Hướng dẫn sử dụng docker compose để cấu hình netbox + nginx làm revser proxy](#hướng-dẫn-sử-dụng-docker-compose-để-cấu-hình-netbox--nginx-làm-revser-proxy)
  - [1. Mô hình docker compose mà tôi build](#1-mô-hình-docker-compose-mà-tôi-build)
  - [2. Hướng dẫn sử dụng](#2-hướng-dẫn-sử-dụng)
  - [3. Hướng dẫn cài đặt plugin netbox-attachments cho netbox](#3-hướng-dẫn-cài-đặt-plugin-netbox-attachments-cho-netbox)
    - [3.1 Các bước cần phải làm](#31-các-bước-cần-phải-làm)
    - [3.2 Các bước thực hành chi tiết](#32-các-bước-thực-hành-chi-tiết)
  - [4. Hướng dẫn cài đặt plugin netbox-inventory](#4-hướng-dẫn-cài-đặt-plugin-netbox-inventory)
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
## 3. Hướng dẫn cài đặt plugin netbox-attachments cho netbox
Link tài liệu được lấy [ở đây](netbox-attachments)

netbox-attachments là một plugin hoặc tính năng trong NetBox, một công cụ quản lý tài sản mạng và tài nguyên hạ tầng. Plugin này cho phép người dùng thêm và quản lý các tệp đính kèm cho các đối tượng trong NetBox
### 3.1 Các bước cần phải làm
- Bước 1: Tải xuống plugin bằng lệnh pip
- Bước 2: Sửa file `configuration.py` để có thể cấu hình plugin
- Bước 3: Chuyển cơ sở dữ liệu cho plugin
### 3.2 Các bước thực hành chi tiết
Bước 1: Truy cập vào container để chạy lệnh tải xuống plugin
```
docker exec -it my_netbox bash
pip install netbox-attachments==5.1.3
```
Bước 2: Tạo 1 session mới trên mobaxterm (không truy cập vào container netbox) để sử file `configuration.py`
```
vi /var/lib/docker/volumes/netbox_netbox-conf/_data/configuration.py
```
Thêm vào cuối file dòng sau:
```
PLUGINS = ['netbox_attachments']
PLUGINS_CONFIG = {
    'netbox_attachments': {
        'apps': ['dcim', 'ipam', 'circuits', 'tenancy', 'virtualization', 'wireless', 'inventory_monitor'],
        'display_default': "right_page",
        'display_setting': {
            'ipam.vlan': "left_page",
            'dcim.device': "full_width_page",
            'dcim.devicerole': "full_width_page",
            'inventory_monitor.probe': "additional_tab"
        }
    }
}
```


![alt text](../anh/Screenshot_50.png)


Bước 3: Ở terminal có truy cập netbox thực hiện lệnh
```
mkdir -p /opt/netbox/netbox/media/netbox-attachments
cd /opt/netbox/netbox/media/
chown unit:root netbox-attachments
```
Bước 4: Di chuyển cơ sở dữ liệu cho plugin
```
python3 manage.py migrate netbox_attachments
```
Bây giờ ta có thể lên interface netbox để kiểm tra kết quả

![alt text](../anh/Screenshot_51.png)

Ta có thể upload ảnh vào virtual machine để kiểm tra kết quả

![alt text](../anh/Screenshot_52.png)


[Một số tùy chỉnh ta có thể tùy chỉnh thêm cho netbox-attachments](https://github.com/Kani999/netbox-attachments?tab=readme-ov-file#plugin-options)


## 4. Hướng dẫn cài đặt plugin netbox-inventory


