/etc/hosts:
    file.managed:
        - source: salt://etc/hosts.jinja
        - template: jinja
        - mode: 644 
