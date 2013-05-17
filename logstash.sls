{% set logstash_confs = pillar.get('logstash', {}).get('confs', []) %}
{% set logstash_patterns = pillar.get('logstash', {}).get('patterns', []) %}
include:
    - java

logstash:
    pkgrepo.managed:
        - name: deb http://ppa.launchpad.net/wolfnet/logstash/ubuntu precise main
        - dist: precise
        - file: /etc/apt/sources.list.d/logstash.list
        - keyid: 28B04E4A
        - keyserver: keyserver.ubuntu.com
    pkg.installed:
        - refresh: True
        - enable: True
        - running: True
        - require:
            - pkgrepo: deb http://ppa.launchpad.net/wolfnet/logstash/ubuntu precise main
            - pkg: java-jre
    service.running:
        - require:
            - pkg: logstash         
        - watch:
              {% for conf in logstash_confs %}
            - file: /etc/logstash/conf.d/{{conf}}.conf
              {% endfor %}

{% for conf in logstash_confs %}
/etc/logstash/conf.d/{{ conf }}.conf:
    file.managed:
        - source: salt://etc/logstash/conf.d/{{ conf }}.jinja
        - template: jinja
        - user: logstash
        - group: logstash
        - mode: 664
        - require:
            - pkg: logstash
{% endfor %}

{% for pattern in logstash_patterns %}
/etc/logstash/patterns/{{ pattern }}:
    file.managed:
        - source: salt://etc/logstash/patterns/{{ pattern }}.jinja
        - template: jinja
        - user: logstash
        - group: logstash
        - mode: 664
        - require:
            - pkg: logstash
{% endfor %}