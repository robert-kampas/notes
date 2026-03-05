```bash
sudo yum update -y
sudo yum update kernel -y
sudo yum install -y ecs-init

sudo mkdir -p /etc/ecs
cat <<EOF | sudo tee /etc/ecs/ecs.config
ECS_CLUSTER=${ECS_CLUSTER}
ECS_BACKEND_HOST=
EOF

sudo systemctl start ecs
sudo systemctl enable ecs
sudo systemctl status ecs

uname -r
```
