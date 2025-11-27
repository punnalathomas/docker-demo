# docker-demo
Demo repository for Docker use. Group work between @punnalathomas and @nlholm.

## How to run

Clone this repository in your computer that has Salt master and minion architecture installed or test it with our ready enviroment by using Vagrantfile.  
HUOMIO: moduuleissa on tietoja mitkä toimivat vain meidän vagrantfilea käyttäen, eli niitä pitää muokata jos ei käytä meidän ympäristöä. Siellä on esimerkiksi käyttäjiä nimellä vagrant
Run commands:  

1. `sudo mkdir -p /srv/salt`
2. `sudo cp -r docker-demo/salt/* /srv/salt/`
3. `sudo salt 'minion1' state.apply`
