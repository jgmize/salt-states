ruby1.9.1-full:
    pkg.installed:
        - refresh: True


/bin/install_kibana.sh:
    file.managed:
        - source: salt://bin/install_kibana.sh.jinja
        - template: jinja
        - mode: 755
        - group: root
        - user: root

      
kibana_install:
    cmd.run:
        - cwd: /var/lib/
        - name: /bin/install_kibana.sh
        - unless: test -e /var/lib/kibana/kibana.rb
        - cwd: /var/lib/
        - require:
            - pkg: ruby1.9.1-full
            - file: /bin/install_kibana.sh
    service.running:
        - name: kibana
        - running: True
        - enable: True
        - watch:
            - file: /var/lib/kibana/KibanaConfig.rb


/etc/init.d/kibana:
    file.managed:
        - source: salt://etc/init.d/kibana.jinja
        - template: jinja
        - user: root
        - group: root
        - mode: 774


/var/lib/kibana/KibanaConfig.rb:
    file.managed:
        - source: salt://var/lib/kibana/KibanaConfig.rb.jinja
        - template: jinja
