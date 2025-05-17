# Hướng dẫn sử dụng Graylog 6.2 với Docker Compose

## Mục đích
Triển khai nhanh hệ thống Graylog 6.2 (gồm MongoDB, DataNode, Graylog Server) bằng Docker Compose.

---

## Lưu ý quan trọng trước khi chạy

**Trước khi chạy docker compose, hãy thiết lập kernel parameter:**
```bash
sudo sysctl -w vm.max_map_count=262144
```
Nên thêm vào `/etc/sysctl.conf` để thiết lập vĩnh viễn.

---

## Bước 1: Clone mã nguồn

```bash
cd /opt/
git clone https://github.com/thanhquang99/Docker
cd Docker/graylog-6.2
```

---

## Bước 2: Tạo mật khẩu và secret

Tạo `password_secret` (chuỗi bí mật để mã hóa dữ liệu):
```bash
openssl rand -hex 32
```
Lấy kết quả làm giá trị cho biến `GRAYLOG_PASSWORD_SECRET`.

Tạo `root_password_sha2` (mật khẩu admin, đã hash SHA256):
```bash
echo -n "Enter Password: " && head -1 </dev/stdin | tr -d '\n' | sha256sum | cut -d" " -f1
```
Lấy kết quả làm giá trị cho biến `GRAYLOG_ROOT_PASSWORD_SHA2`.

---

## Bước 3: Chạy dịch vụ với biến môi trường động (ghi đè biến trong file .env nếu có)

Bạn có thể ghi đè biến môi trường khi chạy Docker Compose bằng tùy chọn `--env` (chỉ hỗ trợ Docker Compose V2):

```bash
docker compose up -d \
  --env GRAYLOG_ROOT_PASSWORD_SHA2=<giá trị_hash> \
  --env GRAYLOG_PASSWORD_SECRET=<chuỗi_bí_mật> \
  --env GRAYLOG_ROOT_JAVA_OPTS="-Xms2g -Xmx2g" \
  --env OPENSEARCH_JAVA_OPTS="-Xms2g -Xmx2g"
```

> **Lưu ý:**  
> Các biến truyền bằng `--env` sẽ ghi đè giá trị trong file `.env` nếu trùng tên.

---

## Truy cập Graylog

- Giao diện web: [http://localhost:9000](http://localhost:9000)
- Đăng nhập với:
  - Username: `admin`
  - Password: (mật khẩu bạn đã chọn ở bước trên)

---

## Quản trị cơ bản

- Xem trạng thái container:
  ```bash
  docker compose ps
  ```
- Xem log:
  ```bash
  docker compose logs -f
  ```
- Dừng dịch vụ:
  ```bash
  docker compose down
  ```

---

## Lưu ý

- Nếu DataNode báo lỗi về `vm.max_map_count`, hãy chạy:
  ```bash
  sudo sysctl -w vm.max_map_count=262144
  ```
  và thêm vào `/etc/sysctl.conf` để thiết lập vĩnh viễn.
- Nếu cần thay đổi cổng hoặc cấu hình, chỉnh sửa file `docker-compose.yml` tương ứng.
- Không để lộ mật khẩu hoặc secret trong file public.

---

## Tham khảo

- [Graylog install](https://go2docs.graylog.org/current/downloading_and_installing_graylog/ubuntu_installation.htm)
- [Docker Compose File Reference](https://github.com/Graylog2/docker-compose)
