{% from "openvstorage/map.jinja" import server with context %}

{%- if server.enabled %}

openvstorage_packages:
  pkg.installed:
    - names: {{ server.pkgs }}

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

ovs_log_directory:
  file.directory:
    - name: /var/log/ovs
    - user: ovs
    - group: cinder
    - mode: 750

{%- endif %}
