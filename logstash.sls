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
        - require:
            - pkgrepo: deb http://ppa.launchpad.net/wolfnet/logstash/ubuntu precise main
            - pkg: java-jre
    service.running:
        - require:
            - pkg: logstash         
        - watch:
            - file: /etc/logstash/conf.d/syslog.conf
#            - file: /etc/logstash/conf.d/mysql_error.conf


/etc/logstash/conf.d/syslog.conf:
    file.managed:
        - source: salt://etc/logstash/conf.d/syslog.conf.jinja
        - template: jinja
        - user: logstash
        - group: logstash
        - mode: 664
        - require:
            - pkg: logstash

#/etc/logstash/conf.d/mysql_error.conf:
#    file.managed:
#        - source: salt://etc/logstash/conf.d/mysql_error.conf.jinja
#        - template: jinja
#        - user: logstash
#        - group: logstash
#        - mode: 664
#        - require:
#            - pkg: logstash
