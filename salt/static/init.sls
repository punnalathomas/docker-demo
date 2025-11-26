copy-static-content:
  dockerng.copy:
    - name: nginx-demo
    - source: salt://static/files
    - dst: /usr/share/nginx/html
    - clean: True
    - require:
        - dockerng.running: nginx-container

