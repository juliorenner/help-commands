# To list and modify interfaces in the host
ip link
# To see the IP addresses assigned to the interfaces listed with ip link
ip addr
# To set IP address in the interfaces
ip addr add
# Assign a node an IP address in interface eth0
ip addr add 192.168.1.10/24 dev eth0
ip addr add 192.168.1.11/24 dev eth0

# Changes with ip addr, ip link, ip addr add, are only persisted until restart
# to make them available after a system restart, the configs need to be done in
# the /etc/network/interfaces file.

# Shows the kernel routing table (both work)
route
ip route
# To add a gateway to communicate with an external network
# where 192.168.2.0/24 is the target network and 192.168.1.1 is the gateway IP
ip route add 192.168.2.0/24 via 192.168.1.1
ip route add 192.168.1.0/24 via 192.168.2.1
# For routes that we don't have a specific gateway, we can point to go through a
# specific gateway, using the `default` name as an alias for `0.0.0.0/0`.
ip route add default via 192.168.2.1
# Using the gateway IP as 0.0.0.0 means that a Gateway is not required. It is
# used to say that it is in the same network.
ip route add 192.168.2.0/24 via 0.0.0.0

# Configuration that allows/disallows a host of forwarding traffic. By default
# value is 0, it should be set to 1.
cat /proc/sys/net/ipv4/ip_forward
echo 1 > /proc/sys/net/ipv4/ip_forward
# Changing /proc/sys/net/ipv4/ip_forward doesn't persist the change across
# reboots, to do that, we need to change /proc/sys/net/ipv4/ip_forward
# net.ipv4.ip_forward = 1
vim /etc/sysctl.conf