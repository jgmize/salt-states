{% set sites = pillar.get('nginx', {}).get('sites', ['default']) %}
nginx:
    pkg:
        - installed
    service:
        - running
        - watch:
{% for site in sites %}
            - file: /etc/nginx/sites-available/{{site}}
{% endfor %}

{% for site in sites %}
/etc/nginx/sites-available/{{site}}:
    file.managed:
        - source: salt://etc/nginx/sites-available/site.jinja
        - template: jinja
        - context:
            site: {{site}}
        - require:
            - pkg: nginx

/etc/nginx/sites-enabled/{{site}}:
    file.symlink:
        - target: /etc/nginx/sites-available/{{site}}

{% endfor %}

#TODO: parameterize into pillar
/var/www/conaff/files:
    file.directory:
        - user: www-data
        - group: www-data
        - mode: 775
        - makedirs: True
