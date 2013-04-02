lxc:
    pkg.installed

lxc_create_base:
    cmd.run:
        - name: 'lxc-create -t ubuntu -n base'
        - unless: test -d /var/lib/lxc/base
        - require:
            - pkg.installed: lxc

bootstrap-salt.sh:
    file.managed:
        - name: /var/lib/lxc/base/rootfs/home/ubuntu/bootstrap-salt.sh
        - source: salt://bin/bootstrap-salt.sh
        - mode: 755
        - require: 
            - cmd.run: lxc_create_base

{% for container in pillar.get('containers', {}) %}
lxc_create_{{container}}:
    cmd.run:
        - name: 'lxc-clone -o base -n {{container}}'
        - unless: test -d /var/lib/lxc/{{container}}
        - require:
            - file: bootstrap-salt.sh

{% set config = pillar.containers.get(container).get('config', {}) %}
{% if config %}
/var/lib/lxc/{{container}}/config:
    file.append:
        - text:
        {% for key, val in config.items() %}
            - {{key}} = {{val}}
        {% endfor %}
        - require:
            - cmd.run: lxc_create_{{container}}
{% endif %}
{% if pillar.containers.get(container).get('auto', True) %}
/etc/lxc/auto/{{container}}:
    file.symlink:
        - target: /var/lib/lxc/{{container}}/config
{% endif %}
{% endfor %}
