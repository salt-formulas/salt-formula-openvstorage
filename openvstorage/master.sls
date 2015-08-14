{% from "openvstorage/map.jinja" import server with context %}

{%- if server.enabled %}

include:
  - openvstorage.common

setup_ovs_master:
  cmd.run:
    - name: "ovs setup master && touch /opt/OpenvStorage/config/ovs_installed"
    # TODO: avahi may be optional
    - creates: /opt/OpenvStorage/config/ovs_installed
    - require:
      - file: preconfig_file

{%- endif %}
