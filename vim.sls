{% set vim_pkg_name = pillar.get('vim_pkg_name') %}
{% if not vim_pkg_name %}
    {% if 'server' in pillar.get('roles', []) %}
        {% set vim_pkg_name = 'vim-nox' %}
    {% else %}
        {% set vim_pkg_name = 'vim-gnome' %}
    {% endif %}
{% endif %}

{{vim_pkg_name}}:
    pkg.installed 
