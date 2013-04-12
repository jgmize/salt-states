# included by user's extended state
# Context from users.sls
# username: {{username}}
# home: {{home}}

include:
    - python

{% include 'git-dotfiles.sls' %}
{% include 'punkt.sls' %}

git://github.com/jgmize/django-document-similarity.git:
    git.latest:
        - runas: {{username}}
        - target: {{home}}/django-document-similarity

numpy_dependencies:
    pkg.installed:
        - names:
            - libatlas-dev
            - liblapack-dev
            - gfortran

numpy:
    pip.installed:
        - require:
            - pkg: numpy_dependencies            

scipy:
    pip.installed:
        - require:
            - pip: numpy

scikit-learn:
    pip.installed:
        - require:
            - pip: scipy

gensim:
    pip.installed:
        - require:
            - pip: scipy

simserver:
    pip.installed:
        - require:
            - pip: gensim

libyaml-dev:
    pkg.installed

PyYAML:
    pip.installed:
        - require:
            - pkg: libyaml-dev


django-document-similarity-requirements:
    pip.installed:
        - requirements: {{home}}/django-document-similarity/requirements.txt
        - require:
            - pip: PyYAML
            - pip: simserver
            - pip: scikit-learn
            - git: git://github.com/jgmize/django-document-similarity.git
