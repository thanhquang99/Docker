# Nội dung file cấu hình của nginx
```
vi /var/lib/docker/volumes/nginx_conf/_data/netbox.conf
```
```
server {
    listen 80;
    server_name netbox.quang.local;  # Thay thế bằng IP hoặc tên miền cụ thể của bạn
    return 301 https://$host$request_uri;  # Chuyển hướng HTTP sang HTTPS
}

server {
    listen 443 ssl;
    server_name netbox.quang.local;  # Thay thế bằng IP hoặc tên miền cụ thể của bạn

    client_max_body_size 25m;

    # SSL Configuration
    ssl_certificate     /etc/nginx/ssl-certificate/localhost.crt;
    ssl_certificate_key /etc/nginx/ssl-certificate/localhost.key;

    # Log
    access_log /var/log/nginx/netbox.access.log;
    error_log /var/log/nginx/netbox.error.log;


    location / {
        proxy_pass http://my_netbox:8080;  # Địa chỉ của ứng dụng NetBox
        proxy_set_header X-Forwarded-Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-Proto $scheme;
    }
}
```
Nội dung các lệnh cấu hình ssl
```
cd ~
openssl genrsa -out CA.key 2048
openssl req -x509 -sha256 -new -nodes -days 3650 -key CA.key -out CA.pem
openssl genrsa -out localhost.key 2048
openssl req -new -key localhost.key -out localhost.csr
sudo tee localhost.ext > /dev/null <<EOF
authorityKeyIdentifier = keyid,issuer
basicConstraints = CA:FALSE
keyUsage = digitalSignature, nonRepudiation, keyEncipherment, dataEncipherment
subjectAltName = @alt_names
[alt_names]
DNS.1 = $Domain_Netbox
EOF
openssl x509 -req -in localhost.csr -CA CA.pem -CAkey CA.key -CAcreateserial -days 365 -sha256 -extfile localhost.ext -out localhost.crt
mv localhost.crt localhost.key /var/lib/docker/volumes/root_nginx-ssl/_data/
```
