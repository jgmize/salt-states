{% set vim_pkg_name = pillar.get('vim_pkg_name') %}
{% if not vim_pkg_namne %}
    {% if 'server' in pillar.get('roles', []) %}
        {% set vim_pkg_name = 'vim-nox' %}
    {% else %}
        {% set vim_pkg_name = 'vim-gnome2' %}
    {% endif %}
{% endif %}

vim:
    pkg.installed: {{vim_pkg_name}}
