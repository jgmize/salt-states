# included by user's extended state
# Context from users.sls
# username: {{username}}
# home: {{home}}

{% include 'git-dotfiles.sls' %}
{% include 'consumeraffairs-dev-user.sls' %}
