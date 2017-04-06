#!/bin/bash
INSTALLLOG=/var/log/zabbix_install.log
DATE=$(date +"%d-%m-%y %T")

#prereq checks
if ! [ $(id -u) = 0 ]; then
   printf  "This script must be run as root!\n"
   exit 1
fi

VER=$(rpm -q --queryformat '%{VERSION}' $(rpm -qa '(redhat|sl|slf|centos|oraclelinux)-release(|-server|-workstation|-client|-computenode)'))

if ! [[ "$VER" =~ ^(5|6|7)$ ]] 
then 
  printf "$DATE Usupported version: $VER\n" | tee -ai $INSTALLLOG
  exit 1
fi

#installation
printf "$DATE Installing zabbix-agent..\n" | tee -ai $INSTALLLOG
rpm -Uvh http://repo.zabbix.com/zabbix/3.0/rhel/$VER/x86_64/zabbix-release-3.0-1.el7.noarch.rpm
yum install -y zabbix-agent &>> $INSTALLLOG 

#configuration
printf "$DATE Configuring zabbix-agent..\n" | tee -ai $INSTALLLOG
sed -i 's/LogFileSize=0/LogFileSize=500/' /etc/zabbix/zabbix_agentd.conf
sed -i 's/Server=127.0.0.1/Server=160.111.100.251/' /etc/zabbix/zabbix_agentd.conf
sed -i 's/ServerActive=127.0.0.1/ServerActive=160.111.100.251/' /etc/zabbix/zabbix_agentd.conf
sed -i 's/Hostname=Zabbix server/Hostname='$HOSTNAME'/' /etc/zabbix/zabbix_agentd.conf
chkconfig --add zabbix-agent
chkconfig zabbix-agent on
service zabbix-agent restart
service zabbix-agent status
printf "\n\n$DATE zabbix-agent configured successfully\n" | tee -ai $INSTALLLOG
printf "$DATE zabbix-agent agent " | tee -ai $INSTALLLOG 
grep "^Hostname=" /etc/zabbix/zabbix_agentd.conf | tee -ai $INSTALLLOG 
printf "\n"
