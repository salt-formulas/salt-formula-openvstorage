{% from "openvstorage/map.jinja" import server with context %}

{%- if server.enabled %}

include:
  - cinder.volume

openvstorage_packages:
  pkg.installed:
    - names: {{ server.pkgs }}
    - watch_in:
      - service: cinder_volume_services

ovs_user:
  user.present:
    - name: ovs
    {%- if not salt['user.info']('ovs') %}
    - home: /opt/OpenvStorage
    - system: True
    - uid: 311
    - gid: 311
    - shell: /bin/bash
    {%- endif %}
    - require_in:
      - pkg: openvstorage_packages

ovs_group:
  group.present:
    - name: ovs
    {%- if not salt['group.info']('ovs') %}
    - system: True
    - gid: 311
    {%- endif %}
    - addusers:
      - cinder
    - require_in:
      - user: ovs_user
    - require:
      - pkg: cinder_volume_packages
    - watch_in:
      - service: cinder_volume_services

preconfig_file:
  file.managed:
    - name: {{ server.preconfig_file }}
    - source: salt://openvstorage/files/preconfig.ini
    - template: jinja
    - mode: 600
    - require:
      - pkg: openvstorage_packages

{%- if server.license is defined %}
license_file:
  file.managed:
    - name: {{ server.config_root }}/licenses
    - content: {{ server.license }}
    - mode: 664
    - user: ovs
    - group: ovs
    - require:
      - pkg: openvstorage_packages
    - require_in:
      - file: preconfig_file
{%- endif %}

{%- if not server.setup.config.memcached %}
memcache_client_config:
  file.managed:
    - name: {{ server.config_root }}/memcacheclient.cfg
    - source: salt://openvstorage/files/memcacheclient.cfg
    - template: jinja
    - mode: 644
    - require:
      - pkg: openvstorage_packages
    - require_in:
      - file: preconfig_file
{%- endif %}

{%- if not server.setup.config.rabbitmq %}
rabbitmq_client_config:
  file.managed:
    - name: {{ server.config_root }}/rabbitmqclient.cfg
    - source: salt://openvstorage/files/rabbitmqclient.cfg
    - template: jinja
    - mode: 644
    - require:
      - pkg: openvstorage_packages
    - require_in:
      - file: preconfig_file
{%- endif %}

{%- endif %}
