openvstorage:
  server:
    enabled: true
    type: master
    setup:
      target:
        ip: 127.0.0.1
        password: dummy
      cluster:
        name: 'cluster_name'
        ip: 127.0.0.1
        join: True
        master:
          ip: 127.0.0.1
          password: dummy
      hypervisor:
        type: KVM
        name: 'hypervisor_name'
        ip: 127.0.0.1
        username: dummy
        password: dummy
      arakoon:
        mountpoint: /mnt/db
      config:
        auto: False
        memcached: False
        rabbitmq: False
      verbose: True
cinder:
  volume:
    enabled: false