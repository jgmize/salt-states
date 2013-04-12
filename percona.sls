add_percona_gpg_key:
    cmd.run:
        - name: 'gpg --keyserver  hkp://keys.gnupg.net --recv-keys 1C4CBDCDCD2EFD2A'
        - unless: test -e /etc/mysql/percona_installed

add_percona_apt_key:
    cmd.run:
        - name: 'gpg -a --export CD2EFD2A | apt-key add -'
        - unless: test -e /etc/mysql/percona_installed
    require:
        - cmd: 'add_percona_gpg_key'

/etc/apt/sources.list:
    file.append: 
        - text:
            - deb http://repo.percona.com/apt precise main
            - deb-src http://repo.percona.com/apt precise main

apt_update:
    cmd.run:
        - name: 'apt-get update -q'
        - unless: test -e /etc/mysql/percona_installed
    require:
        - file: /etc/apt/sources.list
        - cmd: add_percona_apt_key

percona-server-server:
    pkg:
        - installed
    require:
        - cmd: apt_update

percona-toolkit:
    pkg:
        - installed
    require:
        - cmd: apt_update

/etc/mysql/my.cnf:
    file.managed:
        - source: salt://etc/mysql/my.cnf.jinja
        - template: jinja
        - require:
            - pkg: percona-server-server

/etc/mysql/debian.cnf:
    file.managed:
        - source: salt://etc/mysql/debian.cnf.jinja
        - template: jinja
        - require:
            - pkg: percona-server-server

/etc/mysql/percona_installed:
    file.touch:
        - require:
            - pkg: percona-server-server

mysql:
    service:
        - running
        - watch:
            - file: /etc/mysql/my.cnf

{% if 'db_backup' in grains.get('roles', []) %}
/var/backups/database:
    file.directory:
        - mode: 770
        - user: backup
        - group: backup

/var/backups/bin:
    file.directory:
        - mode: 770
        - user: backup
        - group: backup

/var/backups/bin/clean_backups:
    file.managed:
        - source: salt://var/backups/bin/clean_backups
        - mode: 770
        - user: backup
        - group: backup
        - require:
            - file: /var/backups/bin

/var/backups/bin/create_trim_script.py:
    file.managed:
        - source: salt://var/backups/bin/create_trim_script.py
        - mode: 770
        - user: backup
        - group: backup
        - require:
            - file: /var/backups/bin

/var/backups/bin/dbbackup:
    file.managed:
        - source: salt://var/backups/bin/dbbackup.jinja
        - template: jinja
        - mode: 770
        - user: backup
        - group: backup
        - require:
            - file: /var/backups/bin
    cron.present:
        - user: backup
        - minute: 0
        - hour: 7

/var/backups/bin/secure-rsync:
    file.managed:
        - source: salt://var/backups/bin/secure-rsync
        - mode: 770
        - user: backup
        - group: backup
        - require:
            - file: /var/backups/bin
{% endif %}
