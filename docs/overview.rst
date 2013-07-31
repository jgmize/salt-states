Overview
========

Operating System
----------------
Our Linux distribution of choice is Ubuntu_, and while SaltStack itself can be used
in `other environments`_, no efforts have (yet) been made to ensure compatibility of 
these salt states with other distributions or operating systems.

.. _Ubuntu: http://www.ubuntu.com/
.. _other environments:
   http://docs.saltstack.com/topics/installation/index.html#platform-specific-installation-instructions

Linux Containers
----------------

We use LXC_ to manage containers for our development, staging, and
production environments. These states are used to manage physical and virtual hosts
and the containers themselves.

.. _LXC: http://lxc.sourceforge.net/

Database
--------

We use the Percona_ fork of MySQL_, configured to use `binlog replication`_
with nightly backups using mysqldump_ and a daily, weekly, monthly retention
policy.


.. _Percona: http://www.percona.com/software/percona-server
.. _MySQL: http://www.mysql.com/
.. _binlog replication: http://dev.mysql.com/doc/refman/5.5/en/binary-log.html
.. _mysqldump: http://dev.mysql.com/doc/refman/5.5/en/mysqldump.html

Web servers
-----------

We use nginx_ to serve static files and as a proxy to gunicorn_ and other
application servers.

.. _nginx: http://wiki.nginx.org/Main
.. _gunicorn: http://gunicorn.org/

Redis
-----

We use Redis_ for caching_, sessions_, and as a `broker for our celery workers`_,
among other things.

.. _Redis: http://redis.io/
.. _sessions: https://github.com/martinrusev/django-redis-sessions
.. _caching: https://github.com/sebleier/django-redis-cache
.. _broker for our celery workers: http://docs.celeryproject.org/en/latest/getting-started/brokers/redis.html


Process Management
------------------

We use Supervisor_ to launch gunicorn_ and other processes that do not have
their own upstart_ scripts. We also have some experimental states for Circus_,
but have not found it to be quite production ready, yet.

.. _Supervisor: http://supervisord.org/
.. _upstart: http://upstart.ubuntu.com/
.. _Circus: http://circus.readthedocs.org/
