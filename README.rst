=============
Open vStorage
=============

Install and configure Open vStorage master and extra nodes.

Available states
================

.. contents::
    :local:

``openvstorage.server``
-----------------------

Setup OpenvStorage server

Available metadata
==================

.. contents::
    :local:

``metadata.openvstorage.server.master``
---------------------------------------

Setup Open vStorage master node (controller)

``metadata.openvstorage.server.extra``
---------------------------------------

Setup Open vStorage extra node (compute)

Requirements
============

To setup functional Open vStorage, you need to satisfy a few requirements by
other Salt formulas.

- ``linux``

  - update /etc/hosts

- ``openssh``

  - deploy SSH key for communication between hosts

- ``rabbitmq``

  - deploy clustered RabbitMQ on master nodes

- ``memcached``

  - deploy memcached on master nodes

Configuration parameters
========================

For complete list of parameters, please check
``metadata/service/server/{master,extra}.yml``

Example reclass
===============

Common
------

This setup is common for both master and extra nodes.

.. code-block:: yaml

    parameters:
      _param:
        # RabbitMQ
        ovs_rabbitmq_secret_key: dummy
        ovs_rabbitmq_admin_password: dummy
        # Default password for openvstorage
        ovs_rabbitmq_ovs_password: 0penv5tor4ge
        # OVS setup
        ovs_cluster_name: tcpcloud
        # OVS master nodes
        cluster_master01_hostname: ovs01
        cluster_master01_address: 172.19.5.31
        cluster_master02_hostname: ovs02
        cluster_master02_address: 172.19.5.32
        cluster_master03_hostname: ovs03
        cluster_master03_address: 172.19.5.33
        # OVS extra nodes
        cluster_extra01_hostname: tcpcmp01
        cluster_extra01_address: 172.19.5.4

      # Add nodes to /etc/hosts
      linux:
        network:
          host:
            master01:
              address: ${_param:cluster_master01_address}
              names:
              - ${_param:cluster_master01_hostname}
            master02:
              address: ${_param:cluster_master02_address}
              names:
              - ${_param:cluster_master02_hostname}
            master03:
              address: ${_param:cluster_master03_address}
              names:
              - ${_param:cluster_master03_hostname}
            extra01:
              address: ${_param:cluster_extra01_address}
              names:
              - ${_param:cluster_extra01_hostname}

      # Setup OpenSSH so nodes can communicate between each other
      openssh:
        client:
          enabled: true
          user:
            root:
              enabled: true
              user: ${linux:system:user:root}
              private_key: ${private_keys:ovs_cluster}
        server:
          permit_root_login: true
          user:
            root:
              enabled: true
              public_keys:
              - ${public_keys:ovs_cluster}
              user: ${linux:system:user:root}
      public_keys:
        ovs_cluster:
          key: xxx
      private_keys:
        ovs_cluster:
          type: rsa
          key: xxx

Master
------

.. code-block:: yaml

    classes:
      - system.openvstorage.common.ovs_vpc01
      - service.rabbitmq.server.cluster
      - service.memcached.server.single
      - service.openvstorage.master
    parameters:
      rabbitmq:
        server:
          secret_key: ${_param:ovs_rabbitmq_secret_key}
          admin:
            password: ${_param:ovs_rabbitmq_admin_password}
          host:
            '/openstack':
              enabled: false
            '/':
              enabled: true
              user: ovs
              password: ${_param:rabbitmq_ovs_password}
              policies:
              - name: HA
                pattern: '^(volumerouter|ovs_.*)$'
                definition: '{"ha-mode": "all"}'
        cluster:
          enabled: true
          name: openvstorage
          role: ${_param:rabbitmq_cluster_role}
          master: ${_param:cluster_master01_hostname}
          mode: disc
          members:
          - name: ${_param:cluster_master01_hostname}
            host: ${_param:cluster_master01_address}
          - name: ${_param:cluster_master02_hostname}
            host: ${_param:cluster_master02_address}
          - name: ${_param:cluster_master03_hostname}
            host: ${_param:cluster_master03_address}
      memcached:
        server:
          cache_size: 1024

Extra
-----

.. code-block:: yaml

    classes:
      - system.openvstorage.common.ovs_vpc01
      - system.cinder.volume.single
      - system.cinder.volume.backend.openvstorage

Example pillar
==============

.. code-block:: yaml

   parameters:
     openvstorage:
       server:
         enabled: true
         # master or extra
         type: master
         setup:
           # Following parameters are used as an input for `ovs setup`
           target:
             # this node
             ip: 127.0.0.1
             password: dummy
           cluster:
             # cluster informations for joining
             name: ${_param:ovs_cluster_name}
             ip: ${_param:single_address}
             join: True
             master:
               # connection to master node
               ip: ${_param:cluster_master01_address}
               password: dummy
           hypervisor:
             type: KVM
             name: ${_param:ovs_hypervisor_name}
             # only for VMWare
             ip: 127.0.0.1
             username: dummy
             password: dummy
           arakoon:
             mountpoint: /mnt/db
           config:
             # configure disk automatically
             auto: False
             # setup memcached and rabbitmq by `ovs setup`
             memcached: False
             rabbitmq: False
           verbose: True

Read more
=========

* http://doc.openvstorage.com/
