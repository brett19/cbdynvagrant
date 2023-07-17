sudo apt-get -y update
sudo apt-get -y install ca-certificates curlvagrant d gnupg
sudo install -m 0755 -d /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
sudo chmod a+r /etc/apt/keyrings/docker.gpg
echo \
    "deb [arch="$(dpkg --print-architecture)" signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
    "$(. /etc/os-release && echo "$VERSION_CODENAME")" stable" | \
    sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
sudo apt-get -y update
sudo apt-get -y install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
sudo systemctl status docker

# reconfigure docker to expose a tcp connection to control it
sudo mkdir -p /etc/systemd/system/docker.service.d/
sudo tee /etc/systemd/system/docker.service.d/override.conf > /dev/null <<EOT 
[Service]
ExecStart=
ExecStart=/usr/bin/dockerd
EOT
sudo tee /etc/docker/daemon.json > /dev/null <<EOT 
{"hosts": ["tcp://0.0.0.0:2375", "unix:///var/run/docker.sock"]}
EOT
sudo systemctl daemon-reload
sudo systemctl restart docker.service

# identify the interface for our link
IFACE=$(ip -br -4 a sh | grep 192.168.99.5 | awk '{print $1}')

# setup our macvlan0 network to share ip address space with this vagrant
sudo docker network create -d macvlan \
    --subnet=192.168.99.0/24 \
    --ip-range=192.168.99.128/25 \
    --gateway=192.168.99.1 \
    -o parent=$IFACE macvlan0
