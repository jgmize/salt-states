{% set host = grains['host'] %}

/etc/hosts:
    file.append:
        - text:
        {% if host == 'ca3' %}
            - 10.0.3.61        mgmt.iso salt
        {% elif host == 'mgmt' %}
            - 10.0.3.1         ca3
        {% endif %}
