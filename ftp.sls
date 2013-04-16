vsftpd:
    pkg:
        - installed
    service:
        - running
        - watch:
            - file: /etc/vsftpd.conf

/var/www/conaff/files/radio:
    file.directory:
        - user: www-data
        - group: www-data

ftp:
    user.present:
        - home: /var/www/conaff/files/radio
        - require:
            - pkg.installed: vsftpd
            - file.directory: /var/www/conaff/files/radio


/etc/vsftpd.conf:
    file.managed:
        - source: salt://etc/vsftpd.conf.jinja
        - template: jinja
        - require:
            - pkg.installed: vsftpd

# vim:set ft=yaml:
