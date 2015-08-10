{% from "openvstorage/map.jinja" import server with context %}

{%- if server.enabled %}

include:
  - openvstorage.common

setup_ovs_master:
  cmd.run:
    - name: "ovs setup master"
    # TODO: avahi may be optional
    - creates: /etc/avahi/services/ovs_cluster.service
    - require:
      - file: preconfig_file

{%- endif %}
