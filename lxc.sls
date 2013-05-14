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


{% for name, container in pillar.get('lxc_hosts', {}).get(grains['fqdn'], {}).get('containers', {}).items() %}
lxc_create_{{name}}:
    cmd.run:
        - name: 'lxc-clone -o base -n {{name}}'
        - unless: test -d /var/lib/lxc/{{name}}
        - require:
            - file: bootstrap-salt.sh

{% if container.get('auto', True) %}
/etc/lxc/auto/{{name}}:
    file.symlink:
        - target: /var/lib/lxc/{{name}}/config
{% endif %}

{% set eth0 = container.get('eth0') %}
{% if eth0%}
/var/lib/lxc/{{name}}/config:
    file.append:
        - text:
            - lxc.network.ipv4 = {{eth0}}
        - require:
            - cmd.run: lxc_create_{{name}}
{% endif %}
{% endfor %}
