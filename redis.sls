add_redis_ppa:
    cmd.run:
        - name: "add-apt-repository -y ppa:chris-lea/redis-server; apt-get update"
        - unless: test -e /etc/apt/sources.list.d/chris-lea-redis-server-precise.list

redis-server:
    pkg:
        - installed
        - require:
            - cmd: add_redis_ppa
    service:
        - running
        - watch:
            - file: /etc/redis/redis.conf

/etc/redis/redis.conf:
    file.managed:
        - source: salt://etc/redis/redis.conf.jinja
        - template: jinja
        - user: redis
        - group: redis
        - mode: 660
        - require:
            - pkg: redis-server
