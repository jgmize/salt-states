{% for username in pillar.users %}
{% set user = pillar['user'][username] %}
{% set roles = grains.get('roles', []) %}
{% if 'home' in user %}
  {% set home = user.home %}
{% else %}
  {% set home = "/home/%s" % username %}
{% endif %}

{{username}}:
    {% if 'gid' in user %}
    group.present:
        - gid: {{user.gid}}
    {% else %}
    group:
        - present
    {% endif %}
    user.present:
        {% if 'fullname' in user %}
        - fullname: {{user.fullname}}
        {% endif %}
        {% if 'shell' in user%}
        - shell: {{user.shell}}
        {% endif %}
        {% if 'home' in user %}
        - home: {{home}}
        {% endif %}
        {% if 'uid' in user %}
        - uid: {{user.uid}}
        {% endif %}
        {% if 'gid' in user %}
        - gid: {{user.gid}}
        {% endif %}
        {% if 'password' in user %}
        - password: {{user.password}}
        {% endif %}
        - groups:
            - {{username}}
            {% if username in pillar.adm_group %}
            - adm
            {% endif %}
            {% if username in pillar.sudo_group %}
            - sudo
            {% endif %}
            {% if 'salt_master' in roles and username in pillar.salt_group %}
            - salt
            {% endif %}
            {% if 'web' in roles and username in pillar.www_data_group %}
            - www-data
            {% endif %}
            {% if 'nagios' in roles and username in pillar.nagios_group  %}
            - nagios
            {% endif %}
            {% if username in pillar.backup_group %}
            - backup
            {% endif %}
        - require:
            {% if 'web' in roles and username in pillar.www_data_group %}
            - group: www-data
            {% endif %}
            {% if 'salt-master' in roles and username in pillar.salt_group %}
            - group: salt
            {% endif %}
            {% if 'nagios' in roles and username in pillar.nagios_group  %}
            - group: nagios
            {% endif %}
            {% if 'db-backup' in roles and username in pillar.backup_group %}
            - group: backup
            {% endif %}
            - group: {{username}}

{{home}}:
    file.directory:
        - user: {{username}}
        - group: {{username}}
        {% if 'group_writeable_home' in user and user.group_writeable_home %}
        - mode: 2771
        {% else %}
        - mode: 751
        {% endif %}
        - require:
            - user: {{username}}

{% if 'ssh_authorized_keys' in user %}
{{home}}/.ssh:
    file.directory:
        - user: {{username}}
        - group: {{username}}
        - mode: 700
        - require:
            - user: {{username}}
{% endif %}

{% if 'ssh_authorized_keys' in user %}
{% for key in user.ssh_authorized_keys %}
{{username}}_authorized_key_{{loop.index}}:
    ssh_auth:
        - present
        - user: {{username}}
        {% if 'enc' in key %}
        - enc: {{key.enc}}
        {% endif %}
        - name: {{key.key}}
        {% if 'comment' in key %}
        - comment: {{key.comment}} 
        {% endif %}
        {% if 'options' in key %}
        - options: {{key.options}}
        {% endif %}
        - config: {{home}}/.ssh/authorized_keys
        - require:
            - file: {{home}}/.ssh

{% for host, fingerprint in user.get('ssh_known_hosts', {}).items() %}
{{host}}:
    ssh_known_hosts:
        - present
        - user: {{username}}
        - fingerprint: {{fingerprint}}
        - enc: ecdsa
{% endfor %}

{% if 'web' in roles and username in pillar.www_data_group %}
www_data_authorized_key_{{username}}_{{loop.index}}:
    ssh_auth:
        - present
        - user: www-data
        {% if 'enc' in key %}
        - enc: {{key.enc}}
        {% endif %}
        - name: {{key.key}}
        {% if 'comment' in key %}
        - comment: {{key.comment}} 
        {% endif %}
        {% if 'options' in key %}
        - options: {{key.options}}
        {% endif %}
        - config: {{pillar.user['www-data'].home}}/.ssh/authorized_keys
        - require:
            - file: {{pillar.user['www-data'].home}}/.ssh
            - user: www-data
{% endif %}
{% endfor %}{# ssh authorized keys #}
{% endif %}{# ssh authorized keys #}
 
{% if 'extended_state' in user %}
{% include user.extended_state %}
{% endif %}

{% endfor %}{# user #}

{% for username in pillar.get('absent_users', []) %}
{{username}}:
    user.absent
{% endfor %}
# vim:set ft=yaml:
