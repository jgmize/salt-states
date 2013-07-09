include:
    - nodejs

npm_install_mocha_phantomjs:
    cmd.run:
        - name: 'npm install -g phantomjs mocha-phantomjs'
        - cwd: /opt/node
        - unless: test -e /usr/local/bin/mocha-phantomjs
