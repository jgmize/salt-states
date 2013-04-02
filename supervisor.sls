{% set roles = grains.get('roles', []) %}
{% set configs = pillar.get('supervisor', {}).get('configs', []) %}
{% if configs %}
supervisor:
    pkg:
        - installed
    service:
        - running
        - watch:
        {% for conf in configs %}
            - file: /etc/supervisor/conf.d/{{conf}}.conf
        {% endfor %}


{% for conf in configs %}
/etc/supervisor/conf.d/{{conf}}.conf:
    file.managed:
        - source: salt://etc/supervisor/conf.d/conf.jinja
        - template: jinja
        - context:
            conf: {{conf}}
        - mode: 644
        - require:
            - pkg: supervisor
{% endfor %}

upgrade_supervisor:
    cmd.run:
        - name: 'pip install supervisor --upgrade'
        - unless: test -e /usr/local/bin/supervisord
        - require:
            - pkg: supervisor

#new version doesn't find debian config by default
/etc/supervisord.conf:
    file.symlink:
        - target: /etc/supervisor/supervisord.conf
        - require:
            - pkg: supervisor

/usr/bin/supervisord:
    file.symlink:
        - target: /usr/local/bin/supervisord
        - require:
            - cmd: upgrade_supervisor
{% endif %}
