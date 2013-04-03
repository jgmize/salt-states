/opt/node/node-v0.8.11-linux-x64.tar.gz:
    file.managed:
        - source: salt://opt/node/node-v0.8.11-linux-x64.tar.gz
        - makedirs: true

extract_node:
    cmd.run:
        - name: 'tar xzf node-v0.8.11-linux-x64.tar.gz --strip-components=1'
        - cwd: /opt/node
        - unless: test -e /opt/node/bin/node
        - require:
            - file: /opt/node/node-v0.8.11-linux-x64.tar.gz

/usr/local/bin/node:
    file.symlink:
        - target: /opt/node/bin/node
        - require:
            - cmd: extract_node

/usr/local/bin/npm:
    file.symlink:
        - target: /opt/node/bin/npm
        - require:
            - cmd: extract_node
