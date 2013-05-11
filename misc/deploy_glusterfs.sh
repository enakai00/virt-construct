#!/bin/sh

# Install virtual machines
cd /root/virt-construct
for i in $(seq 1 4); do
    n=$i ./virt-construct.py -c conf/glusterfs.conf -s &
    sleep 5
done
wait

# Wait for virtual machines to start
for i in $(seq 1 4); do
    {   res=""
        while [[ $res != "Linux" ]]; do
            res=$(ssh -o "StrictHostKeyChecking no" root@192.168.122.10$i uname)
            sleep 5
        done
    } &
done
wait

# Excecute application configuration commands
ssh -o "StrictHostKeyChecking no" root@192.168.122.101 <<EOF
    gluster peer probe gluster02
    gluster peer probe gluster03
    gluster peer probe gluster04
    sleep 1
    gluster vol create vol01 \
        gluster01:/data/brick01 \
        gluster02:/data/brick01 \
        gluster03:/data/brick01 \
        gluster04:/data/brick01
    sleep 1
    gluster vol start vol01
EOF

