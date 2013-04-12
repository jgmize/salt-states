
/var/log/celery:
    file.directory:
        - user: www-data
        - group: www-data

/var/run/celery:
    file.directory:
        - user: www-data
        - group: www-data

{% if 'celery' in grains.get('roles', []) %}

/etc/init.d/celeryd:
    file.managed:
        - source: salt://etc/init.d/celeryd
        - mode: 755

/etc/default/celeryd:
    file.managed:
        - source: salt://etc/default/celeryd.jinja
        - template: jinja
        - mode: 644
        - require:
            - file.directory: /var/run/celery
            - file.directory: /var/log/celery
celeryd:
    service:
        {% if grains.get('celery_maintenance_mode', False) %}
        - dead
        {% else %}
        - running
        - watch:
            - file: /etc/init.d/celeryd
            - file: /etc/default/celeryd
        {% endif %}
{% endif %}

{% if 'celerybeat' in grains.get('roles', []) %}
/etc/init.d/celerybeat:
    file.managed:
        - source: salt://etc/init.d/celerybeat
        - mode: 755

/etc/default/celerybeat:
    file.managed:
        - source: salt://etc/default/celerybeat.jinja
        - template: jinja
        - mode: 644
        - require:
            - file.directory: /var/run/celery
            - file.directory: /var/log/celery

celerybeat:
    service:
        {% if grains.get('celery_maintenance_mode', False) %}
        - dead
        {% else %}
        - running
        - watch:
            - file: /etc/default/celerybeat
        {% endif %}
{% endif %}
