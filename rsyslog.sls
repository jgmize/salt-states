/etc/rsyslog.conf:
    file.managed:
        - source: salt://etc/rsyslog.jinja
        - template: jinja
        - user: root
        - group: root
        - mode: 664
        - required:
            - pkg: rsyslog

rsyslog:
    pkg:
        - installed
    service:
        - running
        - watch:
            - file: /etc/rsyslog.conf
            - pkg: rsyslog

/var/spool/rsyslog:
    file.directory:
        - user: syslog
        - group: adm
        - mode: 755
        - makedirs: True
        - required:
            - pkg: rsyslog
