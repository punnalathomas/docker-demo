# docker-demo
Demo repository for Docker use. Group work with @punnalathomas.

## How to run

Clone this repository in your computer that has Salt master and minion architecture installed or test it with our ready enviroment by using Vagrantfile.  

Run commands:  

1. `sudo mkdir -p /srv/salt`
2. `sudo cp -r docker-demo/salt/* /srv/salt/`
3. `sudo systemctl restart salt-master`
4. `sudo salt 'minion1' state.apply`
