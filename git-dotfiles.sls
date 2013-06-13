# included by user's extended state
# Context from users.sls
# username: {{username}}
# home: {{home}}

include:
    - vcs
    - utils

{{username}}_vundle:
    git.latest:
        - name: git://github.com/gmarik/vundle.git
        - runas: {{username}}
        - target: {{home}}/.vim/bundle/vundle
        - require:
            - user: {{username}}
            - pkg: git

{{username}}_dotfiles:
    git.latest:
        - name: git://github.com/jgmize/dotfiles.git
        - runas: {{username}}
        - target: {{home}}/dotfiles
        - require:
            - user: {{username}}
            - pkg: git

{{username}}_install_dotfiles:
    cmd:
        - run
        - user: {{username}}
        - shell: /bin/bash
        - cwd: {{home}}
        - name: 'dotfiles/install'
        - unless: test -L {{home}}/.tmux.conf
        - require:
            - git.latest: git://github.com/jgmize/dotfiles.git
            - git.latest: git://github.com/gmarik/vundle.git

# vim:set ft=yaml:
