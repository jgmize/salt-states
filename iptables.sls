iptables-persistent:
    pkg:
        - installed
    service:
        - running
        - watch:
            - file: /etc/iptables/rules.v4
            - file: /etc/init.d/iptables-persistent
            #- file: /etc/iptables/rules.v6 # TODO


/etc/iptables/rules.v4:
    file.managed:
        - source: salt://etc/iptables/rules.v4.jinja
        - template: jinja
        - require:
            - pkg: iptables-persistent


# the packaged version has a couple of issues which our version addresses
# TODO: submit bug report and patch upstream
/etc/init.d/iptables-persistent:
    file.managed:
        - source: salt://etc/init.d/iptables-persistent
        - mode: 755

# TODO: ipv6 rules
#/etc/iptables/rules.v6:
#    file.managed:
#        - source: salt://etc/iptables/rules.v6.jinja
#        - template: jinja
#        - require:
#            - pkg: iptables-persistent
