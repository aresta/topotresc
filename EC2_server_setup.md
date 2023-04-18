
EC2 Topotresc Cloud

# 1er cop des de zero:

## Crear instància
EC2 -> Instances -> Launch Instance
* Name: Topotresc
* Amazon Linux 2023 AMI
* instance_type: t3.medium (2 vCPU, 4GB)
    * (Despres podem canviar a: c5a.2xlarge   (16 vCPU, 32GB))
* Create security group
* Allow SSH from anywhere
* Storage: 100 GB - gp2

## Connectar per SSH
Instances -> Boto Connect -> SSH client
Afegir la clau:
```    
ssh -i ~/aws/certs/topotresc_server.pem ec2-user@ec2-13-39-109-105.eu-west-3.compute.amazonaws.com
```
Nota: l'adreça canvia cada cop que reiniciem la instància

## Instal.lar Docker
```bash
sudo dnf update
sudo dnf install docker

# Add group membership for the default ec2-user so you can run all docker commands without using the sudo command
sudo usermod -a -G docker ec2-user
id ec2-user
# Reload a Linux user's group assignments to docker w/o logout
newgrp docker

# docker-compose
wget https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m)
sudo mv docker-compose-$(uname -s)-$(uname -m) /usr/local/bin/docker-compose
sudo chmod -v +x /usr/local/bin/docker-compose

# Enable docker service at AMI boot time and start
sudo systemctl enable docker.service
sudo systemctl start docker.service
```

### Check
```
sudo systemctl status docker.service
```

## Crear directoris topotresc
```bash
mkdir topotresc
cd topotresc
mkdir tools postgres mnt
mkdir tools/scripts postgres/scripts postgres/data postgres/initdb
mkdir mnt/conf mnt/base_data mnt/contours mnt/openstreetmap-carto mnt/pbf mnt/shades mnt/tiles
```

## Connectar amb Filezila
* SFTP / SSH
* Usuari: ec2-user
* Arxiu de claus: /Users/gos/aws/certs/topotresc_server.pem

Copiar: 
* docker-compose.yml
* mnt/
    * conf : tot
    * openstreetmap-carto : tot
* tools/
    * Dockerfile
    * scripts : tot
* postgres/
    * Dockerfile
    * scripts : tot
    * initdb : tot
    * postgresql.conf  **<= TODO: revisar**

*Nota: No arrencar docker ni copiar res més abans de fer el 1er snapshot*


# Snapshot
Instance: Stop
Volumes -> Actions -> Create Snapshot

En principi es pot borrar el volum i archivar el snapshot (minim 3 mesos)


# Després de restaurar snapshot





 