{% set fqdn = grains['fqdn'] %}

hosts:
    all:
        - 93.184.216.119 example.com

lxc_hosts:
    lxchost.example.com:
        lxcbr0: 10.0.3.1
        eth0: 192.168.0.22
        containers:
            www.example.com:
                eth0: 10.0.3.80
            vpn.example.com:
                eth0: 10.0.3.194
                tun0: 10.254.0.1
            salt.example.com:
                eth0: 10.0.3.45
        port_forwards:
            -
                container: www.example.com
                protocol: tcp
                port: 80
                destination: 10.0.3.80
            -
                container: www.example.com
                protocol: tcp
                port: 443
                destination: 10.0.3.80
            -
                container: vpn.example.com
                protocol: udp
                port: 1194
                destination: 10.0.3.194
            -
                container: salt.example.com
                protocol: tcp
                port: 4505
                destination: 10.0.3.45
            -
                container: salt.example.com
                protocol: tcp
                port: 4506
                destination: 10.0.3.45

{% if fqdn == 'vpn.example.com' %}
oenvpn_server:
    network: 10.254.0.0
    netmask: 255.255.0.0
{% else %}
openvpn_servers:
    - vpn.example.com
{% endif %}
