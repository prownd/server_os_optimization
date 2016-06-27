#!/bin/bash

#author:hanjinpeng
#E-mail 545751287@qq.com

CDSRCDIR=/dev/sr0
CDROMDIR=/media/cdrom
REPO="file://$CDROM"
yumconf=$(mktemp ${TMPDIR:-/tmp}/yum.conf.XXXXXX) 
yumdir=`dirname $yumconf`
TIME=`date +%Y%m%d%H%M`
BEFORE_REPO_FILE_EXIST=false
MOUNTOPTION="mount -t iso9660 -o loop /dev/sr0"
ISMOUNT=false
if [ -d $ISOFTDIR ];then
	if ! $ISMOUNT ;then
		$MOUNTOPTION $ISOFTDIR
		ISMOUNT=true
	fi
else
	if ! $ISMOUNT ;then
		mkdir -p $ISOFTDIR
		$MOUNTOPTION $ISOFTDIR
		ISMOUNT=true
	fi
fi
if [ -d $CDROMDIR ];then
	if ! $ISMOUNT ;then
		$MOUNTOPTION $CDROMDIR
		ISMOUNT=true
	fi
else
	if ! $ISMOUNT ;then
		mkdir -p $CDROMDIR
		$MOUNTOPTION $CDROMDIR
		ISMOUNT=true
	fi
fi

if [ ! -e $yumconf ];then
        if [ ! -d $yumdir ];then
            mkdir -p $yumdir
        fi

cat > $yumconf <<EOF
[local-media]
name=media repo
baseurl=$REPO
enabled=1
gpgcheck=0
EOF
fi

YUM_WITH_OPTION="yum -y -c $yumconf --disablerepo=* --enablerepo=local-media"

if [ -e $yumconf ];then
        $YUM_WITH_OPTION groupinstall base console-internet core debugging directory-client java-platform network-file-system-client performance perl-runtime server-platform web-server web-servlet php turbogears mysql-client postgresql-client

fi



# E-mail 545751287@qq.com
# centos6  optimizate shell scripts
# version 0.3.1
 
check_is_root(){
    if [[ "$(whoami)" != "root" ]]; then
        echo "please run this script as root !" >&2
        exit 1
    fi
    echo -e "\033[31m the script only Support Centos6 x86_64 \033[0m"
    echo -e "\033[31m system initialization script, Please Seriously. press ctrl+C to cancel \033[0m"
}


set_ntp_service(){
    $YUM_WITH_OPTION install ntp
    echo '0 */3 * * * /usr/sbin/ntpdate time.windows.com >/dev/null 2>&1' >>/var/spool/cron/root
    service crond restart
}



limit_file_fd(){
echo "ulimit -SHn 102400" >> /etc/rc.local
cat >> /etc/security/limits.conf << EOF
*           soft   nofile       65535
*           hard   nofile       65535
EOF
}



sysctl_net_optimizate(){ 
cp /etc/sysctl.conf /etc/sysctl.conf-$(date +%F).bak
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
#net.ipv4.icmp_echo_ignore_all = 1
EOF
/sbin/sysctl -p
echo "sysctl set OK!!"
}



#disable ctrl alt delete
disable_ctl_alt_del(){
    #sed -i "s/ca::ctrlaltdel:\/sbin\/shutdown -t3 -r now/#ca::ctrlaltdel:\/sbin\/shutdown -t3 -r now/" /etc/inittab
    #mv /etc/init/control-alt-delete.conf /etc/init/control-alt-delete.conf.bak
    sed -i 's#^exec /sbin/shutdown -r now#\#exec /sbin/shutdown -r now#' /etc/init/control-alt-delete.conf
}



#tty num
set_tty_num(){
    sed -i  's/1-6/1-2/' /etc/sysconfig/init
}



system_user_limit(){
    cp /etc/passwd /etc/passwd-$(date +%F).bak
    for i in xfs news nscd dbus vcsa games nobody avahi haldaemon gopher ftp mailnull pcap mail shutdown halt uucp operator sync adm lp
    do
        sed -i "s/^${i}/#${i}/" /etc/passwd
        echo "${i} done.."
    done
}



history_limit(){
    cp /etc/profile /etc/profile-$(date +%F).bak
    #echo "TMOUT=300" >> /etc/profile
    sed -i '/^HISTSIZE=/cHISTSIZE=100' /etc/profile
    source /etc/profile
    #cat /dev/null >/etc/issue 
    #cat /dev/null >/etc/issue.net 
    #cat /dev/null >/etc/motd
}



chmod_spec_file(){
    #chattr +a /root/.bash_history
    #chattr +i /root/.bash_history
    chmod -R 700 /etc/rc.d/init.d/*
    chmod 700 /bin/rpm
    chmod 664 /etc/hosts
    chmod 644 /etc/passwd
    chmod 644 /etc/exports
    chmod 644 /etc/issue
    chmod 664 /var/log/wtmp
    chmod 664 /var/log/btmp
    chmod 644 /etc/services
    chmod 644 /etc/shadow
    chmod 600 /etc/login.defs
    #chmod 600 /etc/hosts.allow
    #chmod 600 /etc/hosts.deny
    chmod 600 /etc/securetty
    chmod 600 /etc/security
    chmod 600 /etc/ssh/ssh_host_key
    chmod 600 /etc/ssh/sshd_config
    chmod 600 /var/log/lastlog
    chmod 600 /var/log/messages
    chmod 700 /bin/ping
    chmod 700 /usr/bin/vim
    chmod 700 /bin/netstat
    chmod 700 /usr/bin/less
    chmod 700 /usr/bin/tail
    chmod 700 /usr/bin/head
    chmod 700 /bin/cat
    chmod 700 /bin/uname
    chmod 500 /bin/ps

    #for file in /etc/passwd /etc/shadow /etc/group /etc/gshadow /etc/services /etc/inittab /etc/rc.local 
    #do 
    #chattr +i $file 
    #done
}



disable_ipv6(){
cat << EOF
+--------------------------------------------------------------+
|         === Welcome to Disable IPV6 ===                      |
+--------------------------------------------------------------+
EOF
echo "alias net-pf-10 off" >> /etc/modprobe.conf
echo "alias ipv6 off" >> /etc/modprobe.conf
/sbin/chkconfig --level 35 ip6tables off
echo "ipv6 is disabled!"
}



disable_selinux(){
    sed -i '/SELINUX/s/enforcing/disabled/' /etc/selinux/config 
    echo "selinux is disabled,you must reboot!"
}



vim_setting(){
    sed -i "8 s/^/alias vi='vim'/" /root/.bashrc
    echo 'syntax on' > /root/.vimrc
}



ssh_config_setting(){
    cp /etc/ssh/sshd_config /etc/ssh/sshd_config-$(date +%F).bak
    ssh_cf="/etc/ssh/sshd_config" 
    sed -i -e '74 s/^/#/' -i -e '76 s/^/#/' $ssh_cf
    #sed -i "s/#Port 22/Port 2233/" $ssh_cf
    sed -i "s/#UseDNS yes/UseDNS no/" $ssh_cf
    sed -i '/#PermitEmptyPasswords no/cPermitEmptyPasswords yes' $ssh_cf   
    #client
    sed -i -e '44 s/^/#/' -i -e '48 s/^/#/' $ssh_cf
    service sshd restart
    echo "ssh is init is ok.............."
    #chkser
}





turn_off_services(){
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
}


install_spec_pkg(){
    $YUM_WITH_OPTION install sysstat
}


optimiz_main(){
    check_is_root
    set_ntp_service
    limit_file_fd
    sysctl_net_optimizate 
    disable_ctl_alt_del
    set_tty_num
    system_user_limit
    history_limit
    chmod_spec_file
    disable_ipv6
    disable_selinux
    vim_setting
    ssh_config_setting
    turn_off_services
    install_spec_pkg
}

optimiz_main


if [ -e $yumconf ];then
	rm -f $yumconf
fi

if $ISMOUNT;then
	umount $CDSRCDIR
fi

