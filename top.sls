base:
    '*':
        - hosts
        - locale
        - openvpn
        - postfix
        - python
        - rsyslog
        - users
        - utils
        - vcs
    'roles:celery':
        - match: grain
        - celery
        - nagios-nrpe
    'roles:ci':
        - match: grain
        - jenkins
        - consumeraffairs_deps
        - nodejs
        - brunch
        - mocha-phantomjs
    'roles:docsim':
        - match: grain
        - circus
    'roles:ftp':
        - match: grain
        - ftp
    'roles:log_server':
        - match: grain
        - logstash
        - elasticsearch
        - kibana
    'roles:lxc_host':
        - match: grain
        - iptables
        - lxc
        - nagios-nrpe
        - ntp
        - rclocal
        - sysctl
    'roles:nagios':
        - match: grain
        - nagios
    'roles:percona':
        - match: grain
        - percona
    'roles:redis':
        - match: grain
        - redis
    'roles:salt_master':
        - match: grain
        - salt_master
    'roles:stats':
        - match: grain
        - supervisor
        - stats
    'roles:web':
        - match: grain
        - nginx
        - consumeraffairs_deps
        - supervisor
        - nodejs
        - brunch
