#!/usr/bin/env bash

# Update system
yum update -y

# Configure the Katello repos
yum -y localinstall https://fedorapeople.org/groups/katello/releases/yum/3.5/katello/el7/x86_64/katello-repos-latest.rpm

# Installation of packages
yum install -y epel-release
yum -y localinstall https://yum.theforeman.org/releases/1.16/el7/x86_64/foreman-release.rpm
yum -y localinstall https://yum.puppetlabs.com/puppetlabs-release-pc1-el-7.noarch.rpm
yum -y localinstall https://dl.fedoraproject.org/pub/epel/epel-release-latest-7.noarch.rpm
yum -y install foreman-release-scl python-django


# Install Puppet repo and install Puppet
yum -y localinstall https://yum.puppet.com/puppetlabs-release-pc1-el-7.noarch.rpm
yum -y install puppetserver

# Install Katello
yum -y install katello

# Set Hostname
hostnamectl --set-hostname katello.example.com
echo >> 192.168.56.20 katello.example.com katello

# Configure Foreman
foreman-installer --scenario katello

# Turn off SELinux
setenforce 0

# Keep SELinux off after a reboot
sed -i.old "s/^\(SELINUX=\)\(.*\)$/\1permissive/" /etc/selinux/config

# Disable firewall
systemctl disable firewalld.service
systemctl stop firewalld.service

# Install Docker
yum install -y docker

# Disable Docker Selinux
sed -i "s/--selinux-enabled/--selinux-enabled=false/" /etc/sysconfig/docker

# Enable and start enable
systemctl enable docker
systemctl start docker

# Pull Gitlab and Jenkins image
docker pull gitlab/gitlab-ce:rc && docker pull jenkins/jenkins:lts

# Create dirs to Gitlab
mkdir -p /srv/gitlab/{config,logs,data}

# Create Gitlab Container
sudo docker run --detach \
    --hostname gitlab.example.com \
    --env GITLAB_OMNIBUS_CONFIG="external_url 'http://gitlab.example.com/'; gitlab_rails['lfs_enabled'] = true;" \
    --publish 443:443 --publish 80:80 --publish 22:22 \
    --name gitlab \
    --restart always \
    --volume /srv/gitlab/config:/etc/gitlab \
    --volume /srv/gitlab/logs:/var/log/gitlab \
    --volume /srv/gitlab/data:/var/opt/gitlab \
    gitlab/gitlab-ce:latest

# Create Jenkins Container
docker run -d -p 8080:8080 -p 50000:50000 jenkins/jenkins:lts



