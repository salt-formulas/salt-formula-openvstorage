{%- if pillar.openvstorage.server is defined %}

include:
{%- if pillar.openvstorage.server.type == 'master' %}
- openvstorage.master
{%- elif pillar.openvstorage.server.type == 'extra' %}
- openvstorage.extra
{%- endif %}

{%- endif %}
