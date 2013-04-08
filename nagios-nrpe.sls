nagios-nrpe-server:
    pkg:
        - installed
    service:
        - running
        - watch:
            - file: /etc/nagios/nrpe.cfg
            - file: /etc/nagios/nrpe_local.cfg

/etc/nagios/nrpe.cfg:
    file.managed:
        - source: salt://etc/nagios/nrpe.cfg
        - template: jinja
        - require:
            - pkg: nagios-nrpe-server

/etc/nagios/nrpe_local.cfg:
    file.managed:
        - source: salt://etc/nagios/nrpe_local.cfg
        - template: jinja
        - require:
            - pkg: nagios-nrpe-server
