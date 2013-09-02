CoreOS Commands
---------------

## IPTables
    # wide open, flush all
    sudo /sbin/iptables -F

    # Open up networking on local 192.168.0.0/24 range
    sudo /sbin/iptables -A INPUT -p tcp -s 192.168.0.0/24 --dport 4001 -j ACCEPT
    sudo /sbin/iptables -A INPUT -p tcp -s 192.168.0.0/24 --dport 7001 -j ACCEPT

    # Open up networking on local 0.0.0.0 range all
    sudo /sbin/iptables -A INPUT -p tcp -s 0.0.0.0/24 --dport 4001 -j ACCEPT

    # Open up networking for just ports 4001 and 7001
    sudo /sbin/iptables -A INPUT -p tcp --dport 4001 -j ACCEPT
    sudo /sbin/iptables -A INPUT -p tcp --dport 7001 -j ACCEPT

## systemctl

    # stop etcd
    systemctl stop etcd

    # start
    systemctl start etcd

    # list all loaded
    systemctl list-units

    # list everything
    systemctl list-units --all

    # list unit files
    systemctl list-unit-files

## etcd

    # exists in:
    /usr/bin/etcd

    # systemctl file:
    /usr/lib64/systemd/system/etcd.service

    # etcd bootstrap
    /usr/bin/etcd-bootstrap
     