#!/bin/bash
sudo apt-get update -y
sudo apt-get install docker.io -y
sudo usermod -aG docker ubuntu
sudo systemctl enable docker
docker run -d -p 8080:80 nginx