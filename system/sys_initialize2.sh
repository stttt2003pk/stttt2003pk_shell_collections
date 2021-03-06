#!/usr/bin/env bash

#!/bin/bash
author="stttt2003pk"
cat << EOF
+--------------------------------------------------------------+
|         === Welcome to Centos System init ===                |
+--------------------------------------------------------------+
EOF
#update yum
cd /etc/yum.repos.d
mv CentOS-Base.repo  CentOS-Base.repo.bak
wget http://centos.ustc.edu.cn/CentOS-Base.repo.5
mv CentOS-Base.repo.5 CentOS-Base.repo
#update system
yum clean all
yum -y update glibc\*
yum -y update yum\* rpm\* python\*
yum clean all
yum -y update
#set ntp
yum -y install ntp
echo "* 3 * * * /usr/sbin/ntpdate 210.72.145.44 > /dev/null 2>&1" >> /etc/crontab
service crond restart
#set ulimit
echo "ulimit -SHn 102400" >> /etc/rc.local
cat >> /etc/security/limits.conf << EOF
*           soft   nofile       65535
*           hard   nofile       65535
EOF

#set locale
#true > /etc/sysconfig/i18n
#cat >>/etc/sysconfig/i18n<<EOF
#LANG="zh_CN.GB18030"
#SUPPORTED="zh_CN.GB18030:zh_CN:zh:en_US.UTF-8:en_US:en"
#SYSFONT="latarcyrheb-sun16"
#EOF
#set sysctl
true > /etc/sysctl.conf
cat >> /etc/sysctl.conf << EOF
net.ipv4.ip_forward = 0
net.ipv4.conf.default.rp_filter = 1
net.ipv4.conf.default.accept_source_route = 0
kernel.sysrq = 0
kernel.core_uses_pid = 1
net.ipv4.tcp_syncookies = 1
kernel.msgmnb = 65536
kernel.msgmax = 65536
kernel.shmmax = 68719476736
kernel.shmall = 4294967296
net.ipv4.tcp_max_tw_buckets = 6000
net.ipv4.tcp_sack = 1
net.ipv4.tcp_window_scaling = 1
net.ipv4.tcp_rmem = 4096 87380 4194304
net.ipv4.tcp_wmem = 4096 16384 4194304
net.core.wmem_default = 8388608
net.core.rmem_default = 8388608
net.core.rmem_max = 16777216
net.core.wmem_max = 16777216
net.core.netdev_max_backlog = 262144
net.core.somaxconn = 262144
net.ipv4.tcp_max_orphans = 3276800
net.ipv4.tcp_max_syn_backlog = 262144
net.ipv4.tcp_timestamps = 0
net.ipv4.tcp_synack_retries = 1
net.ipv4.tcp_syn_retries = 1
net.ipv4.tcp_tw_recycle = 1
net.ipv4.tcp_tw_reuse = 1
net.ipv4.tcp_mem = 94500000 915000000 927000000
net.ipv4.tcp_fin_timeout = 1
net.ipv4.tcp_keepalive_time = 1200
net.ipv4.ip_local_port_range = 1024 65535
EOF
/sbin/sysctl -p
echo "sysctl set OK!!"
#close ctrl+alt+del
sed -i "s/ca::ctrlaltdel:\/sbin\/shutdown -t3 -r now/#ca::ctrlaltdel:\/sbin\/shutdown -t3 -r now/" /etc/inittab
#set purview
chmod 600 /etc/passwd
chmod 600 /etc/shadow
chmod 600 /etc/group
chmod 600 /etc/gshadow
#disable ipv6
cat << EOF
+--------------------------------------------------------------+
|         === Welcome to Disable IPV6 ===                      |
+--------------------------------------------------------------+
EOF
echo "alias net-pf-10 off" >> /etc/modprobe.conf
echo "alias ipv6 off" >> /etc/modprobe.conf
/sbin/chkconfig --level 35 ip6tables off
echo "ipv6 is disabled!"
#disable selinux
sed -i '/SELINUX/s/enforcing/disabled/' /etc/selinux/config
echo "selinux is disabled,you must reboot!"
#vim
sed -i "8 s/^/alias vi='vim'/" /root/.bashrc
echo 'syntax on' > /root/.vimrc
#zh_cn
sed -i -e 's/^LANG=.*/LANG="en"/'   /etc/sysconfig/i18n
#init_ssh
ssh_cf="/etc/ssh/sshd_config"
sed -i -e '74 s/^/#/' -i -e '76 s/^/#/' $ssh_cf
sed -i "s/#Port 22/Port 65535/" $ssh_cf
sed -i "s/#UseDNS yes/UseDNS no/" $ssh_cf
#client
sed -i -e '44 s/^/#/' -i -e '48 s/^/#/' $ssh_cf
service sshd restart
echo "ssh is init is ok.............."
#chkser
#tunoff services
#--------------------------------------------------------------------------------
cat << EOF
+--------------------------------------------------------------+
|         === Welcome to Tunoff services ===                   |
+--------------------------------------------------------------+
EOF
#---------------------------------------------------------------------------------
for i in `ls /etc/rc3.d/S*`
do
              CURSRV=`echo $i|cut -c 15-`
echo $CURSRV
case $CURSRV in
          crond | irqbalance | microcode_ctl | lvm2-monitor | network | random | sshd | syslog  )
      echo "Base services, Skip!"
      ;;
      *)
          echo "change $CURSRV to off"
          chkconfig --level 235 $CURSRV off
          service $CURSRV stop
      ;;
esac
done
echo "service is init is ok.............."