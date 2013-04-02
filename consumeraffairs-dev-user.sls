# included by user's extended state
# Context from users.sls
# username: {{username}}
# home: {{home}}

{% if username in grains.get('consumeraffairs_dev_users', []) %}
include:
    - python
    - vcs
    - consumeraffairs_deps
    - brunch

mkvirtualenv_{{username}}:
    cmd:
        - run
        - shell: /bin/bash
        - name: 'su - {{username}} -c "bash -l -i -c \"mkvirtualenv ca -a {{home}}/consumeraffairs\""'
        - unless: test -d {{home}}/.virtualenvs/ca
        - require:
            - user: {{username}}
            - cmd: clone_consumeraffairs_{{username}}

pip_install_yaml_{{username}}:
    cmd:
        - run
        - user: {{username}}
        - shell: /bin/bash
        - cwd: {{home}}/consumeraffairs
        - name: '{{home}}/.virtualenvs/ca/bin/pip install PyYAML'
        - unless: test -d {{home}}/.virtualenvs/ca/lib/python2.7/site-packages/yaml
        - require:
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
            - cmd: mkvirtualenv_{{username}}
       
clone_consumeraffairs_{{username}}:
    cmd:
        - run
        - user: {{username}}
        - shell: /bin/bash
        - name: "/usr/bin/hg clone {{pillar.get('consumeraffairs_repo')}}"
        - cwd: {{home}}
        - unless: test -d {{home}}/consumeraffairs
        - require:
            - user: {{username}}

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

{{home}}/consumeraffairs/local_settings.py:
    file.managed:
        - source: salt://consumeraffairs/local_settings.py.jinja
        - template: jinja
        - user: {{username}}
        - group: {{username}}
        - mode: 660
        - require:
            - cmd: clone_consumeraffairs_{{username}}

{% if 'dev' in grains.get('roles', []) %}
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
{% endif %}

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

install_frontend_dependencies:
    cmd.run:
        - name: 'npm install'
        - cwd: {{home}}/consumeraffairs/styleguide/frontend
        - unless: test -d {{home}}/consumeraffairs/styleguide/frontend/node_modules
        - runas: {{username}}

{% endif %}
