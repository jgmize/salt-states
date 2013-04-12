jenkins_ppa:
    pkgrepo.managed:
        - human_name: Jenkins Continuous Integration Server
        - name: deb http://pkg.jenkins-ci.org/debian binary/
        - file: /etc/apt/sources.list.d/jenkins.list
        - key_url: http://pkg.jenkins-ci.org/debian/jenkins-ci.org.key
        - require_in:
            - pkg: jenkins

jenkins_ci:
    pkg.installed:
        - name: jenkins
    service:
        - name: jenkins
        - running
        - watch:
            - pkg: jenkins
