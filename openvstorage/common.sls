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

{%- endif %}
