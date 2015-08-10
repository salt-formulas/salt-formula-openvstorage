{% from "openvstorage/map.jinja" import server with context %}

{%- if server.enabled %}

include:
  - openvstorage.common

setup_ovs_extra:
  cmd.run:
    - name: "ovs setup extra"
    # TODO: avahi may be optional
    - creates: /etc/avahi/services/ovs_cluster.service
    - require:
      - file: preconfig_file

{%- endif %}
