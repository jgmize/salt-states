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

{% if grains['host'] == 'ca3' %}
lxc_create_mgmt:
    cmd.run:
        - name: 'lxc-clone -o base -n mgmt'
        - unless: test -d /var/lib/lxc/mgmt
        - require:
            - file: bootstrap-salt.sh
{% endif %}
