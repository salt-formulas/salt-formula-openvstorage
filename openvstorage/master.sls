{% from "openvstorage/map.jinja" import server with context %}

{%- if server.enabled %}

include:
  - openvstorage.common

setup_ovs_master:
  cmd.run:
    - name: "ovs setup master && echo master > {{ server.config_root }}/ovs_installed"
    - creates: {{ server.config_root }}/ovs_installed
    - require:
      - file: preconfig_file

{%- endif %}
