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

# Hack to allow proxying Open vStorage web UI
setup_allowed_hosts:
  cmd.run:
    - name: |
        "sed -i 's,^ALLOWED_HOSTS.*,ALLOWED_HOSTS\ =\ \[\"\*\"\],g' /opt/OpenvStorage/webapps/api/settings.py; service ovs-webapp-api restart"
    - unless: "grep -E '^ALLOWED_HOSTS' /opt/OpenvStorage/webapps/api/settings.py | grep '*'"
    - require:
      - cmd: setup_ovs_master

{%- endif %}
