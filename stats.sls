include:
    - nginx
    - nodejs
    - vcs

graphite_system_requirements:
    pkg.installed:
        - names:
            - sqlite3
            - libcairo2
            - libcairo2-dev
            - python-cairo
            - memcached

pip_install_whisper_carbon_graphite_web:
    pip.installed:
        - names:
            - whisper
            - carbon
            - graphite-web
            - django==1.3
            - python-memcached
            - django-tagging
            - gunicorn
        #- unless: test -d /opt/graphite
        - require:
            - pkg: libcairo2
            - pkg: libcairo2-dev
            - pkg: python-cairo

/opt/graphite/conf/carbon.conf:
    file.managed:
        - source: salt://opt/graphite/conf/carbon.conf
        - require:
            - pip: pip_install_whisper_carbon_graphite_web

/opt/graphite/conf/storage-schemas.conf:
    file.managed:
        - source: salt://opt/graphite/conf/storage-schemas.conf
        - require:
            - pip: pip_install_whisper_carbon_graphite_web

/opt/graphite/conf/storage-aggregation.conf:
    file.managed:
        - source: salt://opt/graphite/conf/storage-aggregation.conf
        - require:
            - pip: pip_install_whisper_carbon_graphite_web

/opt/graphite/webapp/graphite/local_settings.py:
    file.managed:
        - source: salt://opt/graphite/webapp/graphite/local_settings.py
        - require:
            - pip: pip_install_whisper_carbon_graphite_web

syncdb:
    cmd.run:
        - cwd: /opt/graphite/webapp/graphite
        - name: 'python manage.py syncdb --noinput'
        - unless: test -e /opt/graphite/storage/graphite.db
        - require:
            - file: /opt/graphite/webapp/graphite/local_settings.py

git://github.com/etsy/statsd.git:
    git.latest:
        - target: /opt/statsd
        - unless: test -d /opt/statsd

/opt/statsd/localConfig.js:
    file.managed:
        - source: salt://opt/statsd/localConfig.js
        - require:
            - git: git://github.com/etsy/statsd.git

/opt/graphite/storage:
    file.directory:
        - user: www-data
        - recurse:
            - user
        - require:
            - pip: pip_install_whisper_carbon_graphite_web
