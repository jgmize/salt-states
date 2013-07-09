salt-master:
    pkg:
        - installed
    service:
        - running
        - watch:
            - file: /etc/salt/master

{%- set syndic_master = grains.get('syndic_master') %}
/etc/salt/master:
    file.append:
        - text:
            - "state_verbose: False"
            {%- if syndic_master %}
            - "syndic_master: {{syndic_master}}"
            {%- endif %}

{%- if syndic_master %}
salt-syndic:
    pkg:
        - installed
    service:
        - running
        - watch:
            - file: /etc/salt/master
{%- endif %}
