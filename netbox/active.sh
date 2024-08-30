#!/bin/bash
IP=$(hostname -I | awk '{print $1}')

# Hàm kiểm tra định dạng tên miền
validate_domain() {
    local domain="$1"
    # Biểu thức chính quy để kiểm tra định dạng tên miền
    if [[ "$domain" =~ ^[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$ && "$domain" =~ ^[a-zA-Z0-9]+(\.[a-zA-Z0-9]+)*\.(local|com|net|org)$ ]]; then
        return 0
    else
        return 1
    fi
}

# Yêu cầu người dùng nhập tên miền cho NetBox
while true; do
    read -p "Nhập tên miền cho NetBox (ví dụ: netbox.tenmien.local): " DOMAIN_NETBOX

    # Kiểm tra định dạng tên miền
    if validate_domain "$DOMAIN_NETBOX"; then
        break
    else
        echo "Tên miền không hợp lệ. Vui lòng nhập tên miền theo định dạng hợp lệ (ví dụ: netbox.tenmien.local)."
    fi
done

# Hàm kiểm tra định dạng email
validate_email() {
    local email="$1"
    # Biểu thức chính quy đơn giản để kiểm tra định dạng email
    if [[ ! "$email" =~ ^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$ ]]; then
        return 1
    fi
    return 0
}

# Yêu cầu người dùng nhập thông tin cho superuser
while true; do
    read -p "Nhập địa chỉ email cho NetBox superuser (bắt buộc: user@gmail.com): " NETBOX_EMAIL

    # Kiểm tra định dạng email
    if validate_email "$NETBOX_EMAIL"; then
        break
    else
        echo "Địa chỉ email không hợp lệ. Vui lòng nhập địa chỉ email theo định dạng hợp lệ."
    fi
done

read -p "Nhập tên người dùng (username) cho NetBox superuser: " NETBOX_USERNAME
read -p "Nhập mật khẩu (password) cho NetBox superuser: " NETBOX_PASSWORD

# Kiểm tra nếu các thông tin không được nhập
if [ -z "$NETBOX_USERNAME" ] || [ -z "$NETBOX_PASSWORD" ] || [ -z "$NETBOX_EMAIL" ]; then
    echo "Tên người dùng, mật khẩu và email không được bỏ trống. Vui lòng chạy lại script và nhập thông tin hợp lệ."
    exit 1
fi

# Đường dẫn đến thư mục cấu hình Nginx
NGINX_CONF_DIR="/var/lib/docker/volumes/root_nginx-conf/_data"

# Đường dẫn đến nơi lưu chứng chỉ SSL
SSL_CERT_DIR="/var/lib/docker/volumes/root_nginx-ssl/_data/"

# Chuyển đến thư mục chính của người dùng
cd ~

# Tạo khóa CA
openssl genrsa -out CA.key 2048

# Tạo chứng chỉ CA tự ký
openssl req -x509 -sha256 -new -nodes -days 3650 -key CA.key -out CA.pem

# Tạo khóa riêng cho server
openssl genrsa -out localhost.key 2048

# Tạo yêu cầu ký chứng chỉ (CSR)
openssl req -new -key localhost.key -out localhost.csr

# Tạo file cấu hình mở rộng cho chứng chỉ
tee localhost.ext > /dev/null <<EOF
authorityKeyIdentifier = keyid,issuer
basicConstraints = CA:FALSE
keyUsage = digitalSignature, nonRepudiation, keyEncipherment, dataEncipherment
subjectAltName = @alt_names
[alt_names]
DNS.1 = $DOMAIN_NETBOX
EOF

# Ký chứng chỉ SSL với CA
openssl x509 -req -in localhost.csr -CA CA.pem -CAkey CA.key -CAcreateserial -days 365 -sha256 -extfile localhost.ext -out localhost.crt

# Di chuyển chứng chỉ SSL và khóa riêng đến thư mục cấu hình Nginx
mv localhost.crt localhost.key $SSL_CERT_DIR

# Tạo file cấu hình Nginx cho NetBox
tee $NGINX_CONF_DIR/netbox.conf > /dev/null <<EOF
server {
    listen 80;
    server_name $DOMAIN_NETBOX;
    return 301 https://\$host\$request_uri;
}

server {
    listen 443 ssl;
    server_name $DOMAIN_NETBOX;

    client_max_body_size 25m;

    # SSL Configuration
    ssl_certificate     /etc/nginx/ssl-certificate/localhost.crt;
    ssl_certificate_key /etc/nginx/ssl-certificate/localhost.key;

    # Log
    access_log /var/log/nginx/netbox.access.log;
    error_log /var/log/nginx/netbox.error.log;

    location / {
        proxy_pass http://my_netbox:8080;
        proxy_set_header X-Forwarded-Host \$host;
        proxy_set_header X-Real-IP \$remote_addr;
        proxy_set_header X-Forwarded-Proto \$scheme;
    }
}
EOF

# Khởi động lại dịch vụ Nginx để áp dụng cấu hình mới
docker restart my_nginx

# Xóa các file tạm
rm -rf CA.key CA.pem localhost.csr localhost.ext

echo "Cấu hình Nginx và chứng chỉ SSL đã được thiết lập thành công cho tên miền $DOMAIN_NETBOX."

# Tạo NetBox superuser tự động với thông tin đã nhập
docker compose exec my_netbox bash -c "DJANGO_SUPERUSER_PASSWORD='$NETBOX_PASSWORD' python3 /opt/netbox/netbox/manage.py createsuperuser --no-input --username '$NETBOX_USERNAME' --email '$NETBOX_EMAIL'"

echo "Superuser cho NetBox đã được tạo thành công với username: $NETBOX_USERNAME và email: $NETBOX_EMAIL."

# Ghi thông tin vào file
touch thongtin.txt
echo "Sửa file hosts thành $IP $DOMAIN_NETBOX" >> thongtin.txt
echo "Link truy cập netbox: https://$DOMAIN_NETBOX" >> thongtin.txt
echo "Netbox User: $NETBOX_USERNAME" >> thongtin.txt
echo "Netbox password: $NETBOX_PASSWORD" >> thongtin.txt
echo "netbox mail: $NETBOX_EMAIL" >> thongtin.txt
