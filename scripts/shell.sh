#!/bin/bash
yum install -y docker

service docker start

sudo file -s /dev/sdg
sudo mkfs -t xfs /dev/sdg
mkdir /webroot 
chmod 777 /webroot
sudo mount /dev/sdg /webroot

cat << EOF > /webroot/index.html
<h1>Hello AWS World.</h1>
EOF

docker run -d --name assignment -v /webroot:/usr/share/nginx/html:ro -p 80:80 --restart always nginx