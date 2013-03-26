# included by user's extended state
# Context from users.sls
# username: {{username}}
# home: {{home}}
{% set roles = grains.get('roles', []) %}
{% if 'dev' in roles %}

include:
    - python

mkvirtualenv_{{username}}:
    cmd:
        - run
        - shell: /bin/bash
        - name: 'su - {{username}} -c "bash -l -i -c \"mkvirtualenv ca -a {{home}}/consumeraffairs\""'
        - unless: test -d {{home}}/.virtualenvs/ca
        - require:
            - pkg: virtualenvwrapper
            - user: {{username}}
            - cmd: clone_consumeraffairs_{{username}}

pip_install_yaml_{{username}}:
    pkg.installed:
        - name: libyaml-dev
    cmd:
        - run
        - user: {{username}}
        - shell: /bin/bash
        - cwd: {{home}}/consumeraffairs
        - name: '{{home}}/.virtualenvs/ca/bin/pip install PyYAML'
        - unless: test -d {{home}}/.virtualenvs/ca/lib/python2.7/site-packages/yaml
        - require:
            - pkg: libyaml-dev
            - pkg: build-essential
            - pkg: python-dev
            - cmd: mkvirtualenv_{{username}}

pip_install_PIL_{{username}}:
    cmd:
        - run
        - user: {{username}}
        - shell: /bin/bash
        - cwd: {{home}}/consumeraffairs
        - name: '{{home}}/.virtualenvs/ca/bin/pip install PIL'
        - unless: test -d {{home}}/.virtualenvs/ca/lib/python2.7/site-packages/PIL
        - require:
            - pkg: PIL_dependencies
            - pkg: build-essential
            - pkg: python-dev
            - file: /usr/lib/libfreetype.so
            - file: /usr/lib/libjpeg.so
            - file: /usr/lib/libz.so
            - cmd: mkvirtualenv_{{username}}
       
clone_consumeraffairs_{{username}}:
    cmd:
        - run
        - user: {{username}}
        - shell: /bin/bash
        - name: '/usr/bin/hg clone /var/www/consumeraffairs'
        - cwd: {{home}}
        - unless: test -d {{home}}/consumeraffairs
        - require:
            - user: {{username}}
            - pkg: mercurial
            - cmd: clone_consumeraffairs

pip_install_requirements_{{username}}:
    cmd:
        - run
        - user: {{username}}
        - shell: /bin/bash
        - cwd: {{home}}/consumeraffairs
        - name: '{{home}}/.virtualenvs/ca/bin/pip install -r requirements.txt'
        - unless: test -d {{home}}/.virtualenvs/ca/lib/python2.7/site-packages/redis_cache
        - require:
            - cmd: clone_consumeraffairs_{{username}}
            - cmd: pip_install_PIL_{{username}}
            - cmd: pip_install_yaml_{{username}}
            - pkg: libmysqlclient-dev
            - pkg: libenchant-dev

{{home}}/consumeraffairs/local_settings.py:
    file.managed:
        - source: salt:/{{home}}/consumeraffairs/local_settings.py.jinja
        - template: jinja
        - user: {{username}}
        - group: {{username}}
        - mode: 660
        - require:
            - cmd: clone_consumeraffairs_{{username}}

pip_install_requirements_dev_{{username}}:
    cmd:
        - run
        - user: {{username}}
        - shell: /bin/bash
        - cwd: {{home}}/consumeraffairs
        - name: '{{home}}/.virtualenvs/ca/bin/pip install -r requirements-dev.txt'
        - unless: test -e {{home}}/.virtualenvs/ca/bin/pep8
        - require:
            - cmd: pip_install_requirements_{{username}}

{{username}}_nltk_tokenizers_punkt:
    pkg.installed:
        - name: unzip
    file.managed:
        - name: {{home}}/nltk_data/tokenizers/punkt.zip
        - source: salt://nltk_data/tokenizers/punkt.zip
        - user: {{username}}
        - makedirs: True
        - require:
            - user: {{username}}
    cmd.run:
        - name: 'unzip punkt.zip'
        - cwd: {{home}}/nltk_data/tokenizers
        - unless: test -d {{home}}/nltk_data/tokenizers/punkt
        - user: {{username}}
        - require:
            - file.managed: {{home}}/nltk_data/tokenizers/punkt.zip
            - pkg.installed: unzip
{% endif %}
# vim:set ft=yaml:
