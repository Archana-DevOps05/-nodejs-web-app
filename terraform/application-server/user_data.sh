#! /bin/bash

sudo yum update -y

# Install Docker
sudo yum install docker -y
# sudo amazon-linux-extras install docker

# Start Docker
sudo systemctl start docker

# Enable Docker to run on boot
sudo systemctl enable docker

# Let Jenkins and the current user use docker
sudo usermod -a -G docker ec2-user

# Create a shell script to run the server by taking the image tagged as simple-web-app:release from the ECR 
cat << EOT > start-website
#!/bin/bash
# chkconfig: 2345 20 80
/bin/sh -e -c 'echo $(aws ecr get-login-password --region us-east-1) | docker login -u AWS --password-stdin ${repository_url}'
sudo docker pull ${repository_url}:release
sudo docker run -p 80:8000 ${repository_url}:release
EOT

# Move the script into the specific amazon ec2 linux start up folder, in order for the script to run after boot

sudo mv start-website /etc/init.d
sudo chkconfig --add start-website
sudo chkconfig start-website on

sudo chmod +x /etc/init.d/start-website

# sudo mv start-website /var/lib/cloud/scripts/per-boot/start-website

# Mark the script as executable
# sudo chmod +x /var/lib/cloud/scripts/per-boot/start-website

# Run the script
# /var/lib/cloud/scripts/per-boot/start-website
