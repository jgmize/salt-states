{% set openvpn_server = pillar.get('openvpn_server', None) %}
{% set openvpn_servers = pillar.get('openvpn_servers', []) %}
openvpn:
    pkg:
        - installed
    service:
        - running
        - require:
            - cmd.run: mknod_tun
        - watch:
            {% if openvpn_server %}
            - file: /etc/openvpn/server.conf
            {% endif %}
            {% for server in openvpn_servers %}
            - file: /etc/openvpn/{{server}}.conf
            {% endfor %}

/dev/net:
    file.directory:
        - mode: 755

mknod_tun:
    cmd.run:
        - name: 'mknod /dev/net/tun c 10 200'
        - unless: test -e /dev/net/tun
        - require:
            - file.directory: /dev/net
        
{% if openvpn_server %}
/etc/openvpn/server.conf:
    file.managed:
        - source: salt://etc/openvpn/server.conf.jinja
        - template: jinja
        - require:
            - pkg: openvpn
{% endif %}

{% for server in openvpn_servers %}
/etc/openvpn/{{server}}.conf:
    file.managed:
        - source: salt://etc/openvpn/client.conf.jinja
        - template: jinja
        - context:
            server: {{server}}
        - require:
            - pkg: openvpn
{% endfor %}

# key management is currently a manual process
# cd /path/to/openvpn/easy-rsa/2.0
# . vars
# ./pkitool <client-fqdn>
# or
# ./pkitool --server <server-fqdn>-server
# scp keys/<keyname>.crt <server-fqdn>:.
# scp keys/<keyname>.key <server-fqdn>:.
# scp keys/ca.crt <server-fqdn>:.
# scp keys/dh1024.pem server-fqdn:.  # only needed for openvpn servers
# then ssh to the server and sudo mv the files to /etc/openvn
