/home/vagrant/nginx-demo:
  file.directory:
    - user: vagrant
    - group: vagrant
    - mode: 755

/home/vagrant/nginx-demo/docker-compose.yml:
  file.managed:
    - source: salt://nginx-web/docker-compose.yml
    - user: vagrant
    - group: vagrant
    - mode: 644
    - require:
      - file: /home/vagrant/nginx-demo

/home/vagrant/nginx-demo/site:
  file.recurse:
    - source: salt://nginx-web/site
    - user: vagrant
    - group: vagrant
    - file_mode: 644
    - dir_mode: 755
    - require:
      - file: /home/vagrant/nginx-demo

nginx_web_up:
  cmd.run:
    - name: docker compose up -d
    - cwd: /home/vagrant/nginx-demo
    - require:
      - file: /home/vagrant/nginx-demo/docker-compose.yml
      - file: /home/vagrant/nginx-demo/site
    - unless: "docker ps | grep -q nginx-web1"
