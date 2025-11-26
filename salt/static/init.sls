/static-files-directory:
  file.directory:
    - name: /srv/www/static
    - user: www-data
    - group: www-data
    - makedirs: True

/static-files-index:
  file.recurse:
    - name: /srv/www/static
    - source: salt://static/files
    - clean: True
    - user: www-data
    - group: www-data
