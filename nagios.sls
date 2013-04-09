{% if 'nagios' in grains.get('roles', []) %}
{% set nagios = pillar.get('nagios', {}) %}
php5-fpm:
    pkg:
        - installed
    service:
        - running
        - watch:
            - file: /etc/php5/fpm/pool.d/www.conf

/etc/php5/fpm/pool.d/www.conf:
    file.managed:
        - source: salt://etc/php5/fpm/pool.d/www.conf
        - require:
            - pkg.installed: php5-fpm

nagios_prereqs:
    pkg.installed:
        - names:
            - fcgiwrap              # For running php5 under nginx
            - nagios-nrpe-plugin    # All the standard plugins and commands
            - libdbi-perl           # For talking to MySQL
            - libdbd-mysql-perl     # For talking to MySQL
            - libmysqlclient-dev    # For talking to MySQL
            - build-essential       # For buildiing check_mysql_health
            - libredis-perl         # For talking to Redis
            - python-redis          # For talking to Redis - with Python!

nagiosplugin:
    pip.installed

python-statsd:
    pip.installed

{% set nagios_bin_files = [
    '/usr/local/bin/build_check_mysql_health',  
    '/usr/local/bin/check_redis.pl',
    '/usr/local/bin/get_content.sh',
    '/usr/local/bin/celery_task_queues.py',
    '/usr/local/bin/check_unsent_mail.sh',
    '/usr/local/bin/check_rackspace_cloudfiles.py',
    ]
%}
{% for bin in nagios_bin_files %}
{{bin}}:
    file.managed:
        - source: salt:/{{bin}}
        - user: root
        - group: root
        - mode: 755
{% endfor %}

run_build_check_mysql_health:
    cmd:
        - run
        - name: /usr/local/bin/build_check_mysql_health
        - unless: /usr/bin/test -f /usr/local/nagios/libexec/check_mysql_health
        - require:
            - file: /usr/local/bin/build_check_mysql_health
            - pkg.installed: nagios_prereqs

# 0.72, Oct 05, 2012
/usr/local/bin/check_redis.pl:
    file.managed:
        - source: salt://usr/local/bin/check_redis.pl
        - user: root
        - group: root
        - mode: 755

/etc/nagios3/htpasswd.users:
    file.managed:
        - source: salt://etc/nagios3/htpasswd.users
        - template: jinja
        - require:
            - pkg.installed: nagios3

/etc/nagios3/cgi.cfg:
    file.managed:
        - source: salt://etc/nagios3/cgi.cfg
        - template: jinja
        - require:
            - pkg.installed: nagios3

# Graphite
/var/spool/nagios:
    file.directory:
        - user: nagios
        - group: www-data
        - mode: 770

/var/spool/nagios/graphios:
    file.directory:
        - user: nagios
        - group: www-data
        - mode: 770
        - require:
            - file: /var/spool/nagios

/usr/local/bin/graphios.py:
    file.managed:
        - source: salt://usr/local/bin/graphios.py.jinja
        - template: jinja
        - user: nagios
        - group: www-data
        - mode: 755
        - require:
            - file: /var/spool/nagios/graphios

/etc/init/graphios.conf:
    file.managed:
        - source: salt://etc/init/graphios.conf
        - require:
            - file: /usr/local/bin/graphios.py

graphios:
    service:
        - running
        - watch:
            - file: /usr/local/bin/graphios.py
        - require:
            - file: /etc/init/graphios.conf

{% set nagios_config_files = [
    '/etc/nagios3/conf.d/contacts.cfg',
    '/etc/nagios3/conf.d/contactgroups.cfg',
    '/etc/nagios3/conf.d/commands.cfg',
    '/etc/nagios3/conf.d/timeperiods.cfg',
    '/etc/nagios3/conf.d/hosts.cfg',
    '/etc/nagios3/conf.d/hostgroups.cfg',
    '/etc/nagios3/conf.d/services.cfg',
    ]
%}

/etc/nagios3/nagios.cfg:
    file.managed:
        - source: salt://etc/nagios3/nagios.cfg
        - template: jinja
        - context:
            nagios_config_files: {{nagios_config_files}}
        - require:
            - pkg.installed: nagios3

nagios3:
    pkg:
        - installed
        - require:
            - pkg.installed: php5-fpm
            - pkg.installed: nagios_prereqs
            - cmd.run: run_build_check_mysql_health
            {% for bin in nagios_bin_files -%}
            - file: {{bin}}
            {% endfor %}
    service:
        - running
        - require:
            - file: /var/spool/nagios/graphios
            - pip.installed: nagiosplugin
            - pip.installed: python-statsd
        - watch:
            - file: /etc/nagios3/htpasswd.users
            - file: /etc/nagios3/nagios.cfg
            - file: /etc/nagios3/cgi.cfg
            {% for cf in nagios_config_files %}
            - file: {{cf}}
            {% endfor %}

{% for cf in nagios_config_files %}
{{ cf }}:
    file.managed:
        - source: salt:/{{ cf }}
        - template: jinja
        - context:
            nagios_config_files: {{nagios_config_files}}
        - require:
            - pkg.installed: nagios3
{% endfor %}

/var/lib/nagios3/rw:
    file.directory:
        - user: nagios
        - group: www-data
        - mode: 770

# Uninstall previous files, or files installed by Ubuntu package
{% for cf in nagios.get('config_files_absent', []) %}
{{cf}}:
    file.absent
{% endfor %}

{% endif %} {# role nagios #}
