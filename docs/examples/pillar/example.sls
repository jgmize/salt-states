hosts:
    all:
        - 93.184.216.119 example.com

lxc_hosts:
    example_lxc_host:
        containers:
            example_www_container:
                eth0: 10.0.3.80
        port_forwards:
            -
                container: example_www_container
                protocol: tcp
                port: 80
                destination: 10.0.3.80
            -
                container: example_www_container
                protocol: tcp
                port: 443
                destination: 10.0.3.80

openvpn_servers:
    - vpn.example.com
