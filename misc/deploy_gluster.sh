#!/bin/sh

mkfs.ext4 -I 512 /dev/vdb
echo "/dev/vdb /data ext4 defaults 0 0" >> /etc/fstab
mkdir -p /data
mount /data

BASEURL=http://download.gluster.org/pub/gluster/glusterfs/3.3/3.3.0/RHEL
yum -y install \
    $BASEURL/glusterfs-3.3.0-1.el6.x86_64.rpm \
    $BASEURL/glusterfs-fuse-3.3.0-1.el6.x86_64.rpm \
    $BASEURL/glusterfs-server-3.3.0-1.el6.x86_64.rpm \
    $BASEURL/glusterfs-geo-replication-3.3.0-1.el6.x86_64.rpm

cat <<'EOF' > /etc/sysconfig/iptables
*filter
:INPUT ACCEPT [0:0]
:FORWARD ACCEPT [0:0]
:OUTPUT ACCEPT [0:0]
-A INPUT -m state --state ESTABLISHED,RELATED -j ACCEPT
-A INPUT -p icmp -j ACCEPT
-A INPUT -i lo -j ACCEPT
-A INPUT -m state --state NEW -m tcp -p tcp --dport 22 -j ACCEPT
-A INPUT -m state --state NEW -m tcp -p tcp --dport 111 -j ACCEPT
-A INPUT -m state --state NEW -m tcp -p tcp --dport 24007:24020 -j ACCEPT
-A INPUT -m state --state NEW -m tcp -p tcp --dport 38465:38467 -j ACCEPT
-A INPUT -j REJECT --reject-with icmp-host-prohibited
-A FORWARD -j REJECT --reject-with icmp-host-prohibited
COMMIT
EOF

cat <<'EOF' >> /etc/rc.local
sysctl -w vm.swappiness=10;
sysctl -w vm.dirty_background_ratio=1;
sysctl -w kernel.sched_wakeup_granularity_ns=15
for i in $(ls -d /sys/block/*/queue/iosched 2>/dev/null); do
    iosched_dir=$(echo $i | awk '/iosched/ {print $1}')
    [ -z $iosched_dir ] && {
    continue
    }
    path=$(dirname $iosched_dir)
    [ -f $path/scheduler ] && {
    echo "deadline" > $path/scheduler
    }
    [ -f $path/nr_requests ] && {
    echo "256" > $path/nr_requests
    }
done
EOF
