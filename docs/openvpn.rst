OpenVPN
=======

Certificates
------------

We use easy-rsa_ 2.0 to build our ca, certificates, and keys.
A copy is distributed with the Ubuntu openvpn package in the
/usr/share/doc/openvpn/examples/easy-rsa/2.0 directory.

While the OpenVPN configuration is managed by salt, certificate and 
key management are still manual.

.. _easy-rsa: https://github.com/OpenVPN/easy-rsa/blob/master/doc/README-2.0

Creating a new Certificate Authority
------------------------------------

The easy-rsa_ docs explain the details, but the basic steps are::

    cd /etc/openvpn  # or wherever you want to store your CA
    mkdir easy-rsa
    cp /usr/share/doc/openvpn/examples/easy-rsa/2.0/* easy-rsa
    cd easy-rsa
    vi vars  # see easy-rsa docs for details on what to change
    source vars
    ./clean-all
    ./build-dh
    ./pkitool --initca


Configuring a new OpenVPN server
--------------------------------

In the example pillar distributed in this repository under
docs/examples/pillar/example.sls we have vpn.example.com configured as
a container on lxchost.example.com. It is listening on the default
UDP port 1194, so we have configured a port forward on the host so that
other hosts can use it. We have chosen 10.254.0.0/16 as our VPN network
for this server, and all VPN clients that connect to that server will be auto assigned an IP on that network. 

While the openvpn configuration is managed through salt, the actual key
and certificate management is still manual, so after the container has 
been created, bootstrapped, and had its first highstate that installed 
openvpn, we need to generate the key and cert and copy them to
/etc/openvpn::

    cd /etc/openvpn/easy-rsa
    source vars
    ./pkitool --server vpn.example.com
    sudo cp keys/vpn.example.com.* /etc/openvpn/
    sudo cp keys/ca.crt /etc/openvpn/
    sudo service openvpn restart

The above assumes that the Certificate Authority was previously
installed and initialized on the same host. If the CA is on a separate 
host, you will need to use a different method to copy the files, such 
as scp. Note that the key name matches the FQDN of the host, which is 
what the conf file managed by the salt state expects.


OpenVPN Client
--------------

After the client has gone through its first highstate which installs 
and configures OpenVPN, generate the client key and cert on the host 
that has Certificate Authority installed and scp the files over::

    cd /etc/openvpn/easy-rsa
    source vars
    ./pkitool www.example.com
    scp keys/www.example.com.* www.example.com:/etc/openvpn/
    scp keys/ca.crt www.example.com:/etc/openvpn/

After you restart the openvpn service on www.example.com, you should 
see a tun0 interface with an IP address in the 10.254.0.0/16 subnet in
the output of ifconfig, and you should be able to ping
vpn.example.com's VPN interface at 10.254.0.1.
