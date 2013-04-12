include:
    - python

libevent-dev:
    pkg.installed

gevent:
    pip.installed:
        - require:
            - pkg: libevent-dev

chaussette:
    pip.installed

/etc/init/circus.conf:
    file.managed:
        - source: salt://etc/init/circus.conf.jinja
        - template: jinja

/etc/circus.ini:
    file.managed:
        - source: salt://etc/circus.ini.jinja
        - template: jinja

/etc/init.d/circus:
    file.symlink:
        - target: /lib/init/upstart-job

circus:
    pip:
        - installed
    service.running:
        - require:
            - pip: gevent
            - pip: chaussette
        - watch:
            - file: /etc/circus.ini
            - file: /etc/init/circus.conf
            - file: /etc/init.d/circus

