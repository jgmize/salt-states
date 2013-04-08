base:
    '*':
        - hosts
        - openvpn
        - python
        - rsyslog
        - users
        - utils
        - vcs
    'roles:ci':
        - match: grain
        - jenkins
        - consumeraffairs_deps
        - nodejs
        - brunch
    'roles:logstash':
        - match: grain
        - logstash
    'roles:elasticsearch':
        - match: grain
        - elasticsearch
#        - kibana
    'roles:lxc_host':
        - match: grain
        - iptables
        - lxc
        - nagios-nrpe
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
