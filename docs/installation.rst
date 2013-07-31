Installation
============

First, `install Ubuntu server`_. (The desktop version, Kubunu, etc. should also work)

.. _install Ubuntu server: http://www.ubuntu.com/download/server/install-ubuntu-server


Next, download and run salt-bootstrap_::

    wget http://bootstrap.saltstack.org -O - | sudo sh

If you're feeling paranoid, you might want to see what it's doing first::

    wget http://bootstrap.saltstack.org -O /tmp/salt-bootstrap.sh
    less /tmp/salt-bootstrap.sh
    # carefully review before executing...
    sudo sh /tmp/salt-bootstrap.sh

.. _salt-bootstrap: https://github.com/saltstack/salt-bootstrap


Adding a Minion to an existing master
-------------------------------------

If you're just pointing the minion to an existing master, just follow the
instructions_ in the official salt walkthrough.

.. _instructions:
   http://docs.saltstack.com/topics/tutorials/walkthrough.html#setting-up-a-salt-minion


Starting a new Master or a Standalone minion
--------------------------------------------

Clone the ConsumerAffairs salt-states repository (or your fork) and move it to
/srv/salt::

    sudo apt-get install git
    git clone https://github.com/ConsumerAffairs/salt-states
    sudo mv salt-states /srv/salt

Alternatively, you can use a symlink or change the file_roots_ setting

.. _file_roots: http://docs.saltstack.com/ref/file_server/file_roots.html

If you're building a new salt master_::

    sudo apt-get install salt-master

.. _master: http://docs.saltstack.com/ref/configuration/master.html

You can also run the minion standalone_ by changing the file_client setting
in /etc/salt/minion to local.

.. _standalone:
   http://docs.saltstack.com/topics/tutorials/standalone_minion.html

Most of our salt states make use of pillar_. You can get a new pillar started
by copying the example from this repository to the default location::

    sudo cp /srv/salt/docs/examples/pillar /srv/pillar

(If you want it somewhere else, just change the pillar_roots setting in the
master config file.)

.. _pillar: http://docs.saltstack.com/topics/pillar/index.html
