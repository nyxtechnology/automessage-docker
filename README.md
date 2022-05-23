### To run project from Dockerfile
- The environment variables are in the `docker-compose.yml` file. Change them according to your production environment. 
  settings
- In terminal use the command `docker build -f Dockerfile -t nyxtechnology/automessage .` to build the automessage in 
  your system from dockerfile
- In docker/php-apache use the command `docker-compose up` to initialize docker containers
- If you want to access the container in your terminal use the following command `docker-compose exec <container name> 
  bash`
