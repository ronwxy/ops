#!/bin/bash

#关闭防火墙
systemctl disable firewalld
systemctl stop firewalld

#关闭selinux
setenforce 0
#永久关闭
sed -i "s/SELINUX=enforcing/SELINUX=disabled/" /etc/sysconfig/selinux
sed -i "s/SELINUX=enforcing/SELINUX=disabled/g" /etc/selinux/config

#禁用swap
swapoff -a
#永久禁用
sed -i "s/.*swap.*/#&/" /etc/fstab

#修改内核参数
cat <<EOF >  /etc/sysctl.d/k8s.conf
net.bridge.bridge-nf-call-ip6tables = 1
net.bridge.bridge-nf-call-iptables = 1
EOF

#重新加载配置文件
sysctl --system

#配置阿里k8s yum源
cat <<EOF > /etc/yum.repos.d/kubernetes.repo
[kubernetes]
name=Kubernetes
baseurl=https://mirrors.aliyun.com/kubernetes/yum/repos/kubernetes-el7-x86_64/
enabled=1
gpgcheck=1
repo_gpgcheck=1
gpgkey=https://mirrors.aliyun.com/kubernetes/yum/doc/yum-key.gpg https://mirrors.aliyun.com/kubernetes/yum/doc/rpm-package-key.gpg
EOF

#更新缓存
yum clean all -y && yum makecache -y && yum repolist -y
