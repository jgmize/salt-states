salt-master:
    pkg:
        - installed
    service:
        - running
        - watch:
            - file: /etc/salt/master

/etc/salt/master:
    file.append:
        - text:
            - "state_verbose: False"
