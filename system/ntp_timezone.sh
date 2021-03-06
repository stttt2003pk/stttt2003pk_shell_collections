#!/usr/bin/env bash

#########################################
#Function:    update time
#Usage:       bash update_time.sh
#Author:      Customer service department
#Company:     Alibaba Cloud Computing
#Version:     2.0
#########################################

check_os_release()
{
  while true
  do
    os_release=$(grep "Red Hat Enterprise Linux Server release" /etc/issue 2>/dev/null)
    os_release_2=$(grep "Red Hat Enterprise Linux Server release" /etc/redhat-release 2>/dev/null)
    if [ "$os_release" ] && [ "$os_release_2" ]
    then
      echo "$os_release"
      break
    fi
    os_release=$(grep "CentOS release" /etc/issue 2>/dev/null)
    os_release_2=$(grep "CentOS release" /etc/*release 2>/dev/null)
    if [ "$os_release" ] && [ "$os_release_2" ]
    then
      echo "$os_release"
      break
    fi
    os_release=$(grep -i "ubuntu" /etc/issue 2>/dev/null)
    os_release_2=$(grep -i "ubuntu" /etc/lsb-release 2>/dev/null)
    if [ "$os_release" ] && [ "$os_release_2" ]
    then
      echo "$os_release"
      break
    fi
    os_release=$(grep -i "debian" /etc/issue 2>/dev/null)
    os_release_2=$(grep -i "debian" /proc/version 2>/dev/null)
    if [ "$os_release" ] && [ "$os_release_2" ]
    then
      echo "$os_release"
      break
    fi
    break
    done
}

modify_rhel5_yum()
{
  rpm --import http://mirrors.163.com/centos/RPM-GPG-KEY-CentOS-5
  cd /etc/yum.repos.d/
  wget http://mirrors.163.com/.help/CentOS-Base-163.repo -O CentOS-Base-163.repo
  sed -i '/mirrorlist/d' CentOS-Base-163.repo
  sed -i 's/\$releasever/5/' CentOS-Base-163.repo
  yum clean metadata
  yum makecache
  cd ~
}

modify_rhel6_yum()
{
  rpm --import http://mirrors.163.com/centos/RPM-GPG-KEY-CentOS-6
  cd /etc/yum.repos.d/
  wget http://mirrors.163.com/.help/CentOS-Base-163.repo -O CentOS-Base-163.repo
  sed -i '/mirrorlist/d' CentOS-Base-163.repo
  sed -i '/\[addons\]/,/^$/d' CentOS-Base-163.repo
  sed -i 's/\$releasever/6/' CentOS-Base-163.repo
  sed -i 's/RPM-GPG-KEY-CentOS-5/RPM-GPG-KEY-CentOS-6/' CentOS-Base-163.repo
  yum clean metadata
  yum makecache
  cd ~
}

config_time_zone()
{
  if [ "$os_type" == "redhat" ]
  then
    if [ -e "/usr/share/zoneinfo/Asia/Shanghai" ]
    then
      echo -e "\033[40;32mStep1:Begin to config time zone.\n\033[40;37m"
      cp -fp /usr/share/zoneinfo/Asia/Shanghai /etc/localtime
      echo -e "ZONE=\"Asia/Shanghai\"\nUTC=false\nARC=false">/etc/sysconfig/clock
    fi
  elif [ "$os_type" == "ubuntu" ] || [ "$os_type" == "debian" ]
  then
    echo -e "\033[40;32mStep1:Begin to config time zone.\n\033[40;37m"
    cp -fp /usr/share/zoneinfo/Asia/Shanghai /etc/localtime
  fi
}

update_debian_apt_source()
{
cat >> /etc/apt/sources.list <<EOF
deb http://mirrors.sohu.com/debian/ lenny main non-free contrib
deb http://mirrors.sohu.com/debian/ lenny-proposed-updates main non-free contrib
deb-src http://mirrors.sohu.com/debian/ lenny main non-free contrib
deb-src http://mirrors.sohu.com/debian/ lenny-proposed-updates main non-free contrib
deb http://mirrors.163.com/debian squeeze main
deb  http://ftp.tw.debian.org/debian/ lenny main contrib non-free
deb-src  http://ftp.tw.debian.org/debian lenny main contrib non-free

deb http://mirrors.163.com/debian/ lenny main contrib non-free
deb-src http://mirrors.163.com/debian lenny main contrib non-free

deb http://mirrors.geekbone.org/debian/ lenny main contrib non-free
deb-src http://mirrors.geekbone.org/debian/ lenny main contrib non-free

deb http://ftp.us.debian.org/debian/ lenny main contrib non-free
deb-src http://ftp.us.debian.org/debian/ lenny main contrib non-free
EOF
apt-get update
}

install_ntp()
{
  case "$os_type" in
  redhat|centos)
    if ! rpm -q ntp >/dev/null 2>&1
    then
       if grep "163.com" /etc/yum.repos.d/* >/dev/null 2>&1
       then
         if ! yum install ntp -y
         then
           echo "Can not install ntp.Script will end."
	   rm -rf $LOCKfile
           exit 1
         fi
       else
         echo "$os_release" |grep 5 >/dev/null
         if [ $? -eq 0 ]
         then
           modify_rhel5_yum
           if ! yum install ntp -y
           then
             echo "Can not install ntp.Script will end."
	     rm -rf $LOCKfile
             exit 1
           fi
         else
           echo "$os_release"|grep 6 >/dev/null
           if [ $? -eq 0 ]
           then
             modify_rhel6_yum
             if ! yum install ntp -y
             then
               echo "Can not install ntp.Script will end."
	       rm -rf $LOCKfile
               exit 1
             fi
           else
             echo "The OS is not RHEL5 or RHEL6."
	     rm -rf $LOCKfile
             exit 0
           fi
         fi
       fi
     fi
     ;;
  ubuntu)
    if ! dpkg -l|grep -w ntp >/dev/null 2>&1
    then
      if ! apt-get install ntp ntpdate -y
      then
        echo "Can not install ntp.Script will end."
	rm -rf $LOCKfile
        exit 1
      fi
    fi
    ;;
  debian)
    update_debian_apt_source
    if ! dpkg -l|grep -w ntp >/dev/null 2>&1
    then
      if ! apt-get install ntp ntpdate -y
      then
        echo "Can not install ntp.Script will end."
	rm -rf $LOCKfile
        exit 1
      fi
    fi
    ;;
  esac
}

mod_config_file()
{
  if [ "$os_type" == "redhat" ] || [ "$os_type" == "centos" ]
  then
     if ! grep "aliyun.com" /etc/ntp/step-tickers >/dev/null 2>&1
     then
       echo -e "ntp1.aliyun.com\nntp1.aliyun.com\nntp1.aliyun.com\n0.asia.pool.ntp.org\n210.72.145.44">>/etc/ntp/step-tickers
     fi
  fi
  if ! grep "aliyun.com" /etc/ntp.conf >/dev/null 2>&1
  then
    echo -e "server ntp1.aliyun.com prefer\nserver ntp2.aliyun.com\nserver ntp3.aliyun.com\nserver 0.asia.pool.ntp.org\nserver 210.72.145.44">>/etc/ntp.conf
  fi
}

install_chkconfig()
{
  if [ "$os_type" == "redhat" ] || [ "$os_type" == "centos" ]
  then
     yum install chkconfig -y
  elif [ "$os_type" == "ubuntu" ] || [ "$os_type" == "debian" ]
  then
     apt-get install rcconf dialog whiptail -y --force-yes --fix-missing
  fi
}

####################Start###################
#check lock file ,one time only let the script run one time
LOCKfile=/tmp/.update_time_lock
if [ -f "$LOCKfile" ]
then
  echo -e "\033[1;40;31mThe script is already exist,please next time to run this script.\n\033[0m"
  exit
else
  echo -e "\033[40;32mStep 1.No lock file,begin to create lock file and continue.\n\033[40;37m"
  touch $LOCKfile
fi

#check user
if [ $(id -u) != "0" ]
then
  echo -e "\033[1;40;31mError: You must be root to run this script, please use root to install this script.\n\033[0m"
  rm -rf $LOCKfile
  exit 1
fi
os_release=$(check_os_release)
if [ "X$os_release" == "X" ]
then
  echo -e "\033[1;40;31mThe OS does not identify,So this script is not executede.\n\033[0m"
  rm -rf $LOCKfile
  exit 0
else
  echo -e "\033[40;32mThis OS is $os_release.\n\033[40;37m"
fi

if echo "$os_release"|grep -i "Red Hat" >/dev/null 2>&1
then
  os_type=redhat
elif echo "$os_release"|grep -i "centos" >/dev/null 2>&1
then
  os_type=centos
elif echo "$os_release"|grep -i "ubuntu" >/dev/null 2>&1
then
  os_type=ubuntu
elif echo "$os_release"|grep -i "debian" >/dev/null 2>&1
then
  os_type=debian
else
  echo -e "\033[1;40;31mThe OS does not identify,So this script is not executede.\n\033[0m"
  rm -rf $LOCKfile
  exit 0
fi

config_time_zone

echo -e "\033[40;32mStep2:Check ntp package and if not to install it.\n\033[40;37m"
install_ntp

echo -e "\033[40;32mStep3:Modify the ntp config file.\n\033[40;37m"
mod_config_file

echo -e "\033[40;32mStep4:Begin to update time...\n\033[40;37m"
ntpdate -u ntp1.aliyun.com
ntpdate -u ntp2.aliyun.com

echo -e "\033[40;32mStep5:Restart ntp service...\n\033[40;37m"
if [ "$os_type" == "redhat" ] || [ "$os_type" == "centos" ]
then
   service ntpd restart
elif [ "$os_type" == "ubuntu" ] || [ "$os_type" == "debian" ]
then
   service ntp restart
fi

install_chkconfig
if [ "$os_type" == "redhat" ] || [ "$os_type" == "centos" ]
then
   chkconfig --level 2345 ntpd on
elif [ "$os_type" == "ubuntu" ] || [ "$os_type" == "debian" ]
then
   rcconf --on ntp
fi
echo -e "\033[40;32mStep6:The NTP service is configured to start automatically at runlevels 2345.\n\033[40;37m"
rm -rf $LOCKfile