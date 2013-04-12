#did not add punkt.zip to salt repo b/c not sure of nltk data license.
#TODO: automate nltk.download() and zip creation
{{username}}_nltk_tokenizers_punkt:
    pkg.installed:
        - name: unzip
    file.managed:
        - name: {{home}}/nltk_data/tokenizers/punkt.zip
        - source: salt://nltk_data/tokenizers/punkt.zip
        - user: {{username}}
        - makedirs: True
        - require:
            - user: {{username}}
    cmd.run:
        - name: 'unzip punkt.zip'
        - cwd: {{home}}/nltk_data/tokenizers
        - unless: test -d {{home}}/nltk_data/tokenizers/punkt
        - user: {{username}}
        - require:
            - file.managed: {{home}}/nltk_data/tokenizers/punkt.zip
            - pkg.installed: unzip
