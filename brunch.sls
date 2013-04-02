include:
    - nodejs


install_brunch:
    cmd.run:
        - name: 'npm install brunch@1.4.1'
        - cwd: /opt/node
        - unless: 'brunch -v | grep -q 1.4.1'

/usr/local/bin/brunch:
    file.symlink:
        - target: /opt/node/node_modules/brunch/bin/brunch
        - require:
            - cmd: install_brunch
