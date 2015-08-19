{% from "openvstorage/map.jinja" import server with context %}

{%- if server.enabled %}

include:
  - openvstorage.common

setup_ovs_extra:
  cmd.run:
    - name: "ovs setup extra && echo extra > {{ server.config_root }}/ovs_installed"
    - creates: {{ server.config_root }}/ovs_installed
    - require:
      - file: preconfig_file

{%- endif %}
