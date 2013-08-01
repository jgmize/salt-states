{% set fqdn = grains['fqdn'] %}

hosts:
    all:
        - 93.184.216.119 example.com

lxc_hosts:
    example_lxc_host:
        containers:
            www.example.com:
                eth0: 10.0.3.80
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

{% if fqdn == 'vpn.example.com' %}
oenvpn_server:
    network: 10.254.0.0
    netmask: 255.255.0.0
{% else %}
openvpn_servers:
    - vpn.example.com
{% endif %}
