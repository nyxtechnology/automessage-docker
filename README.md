### To run project from Dockerfile

- In root directory and docker/php-apache rename the `.env.example` file to `.env`.
- Change the variables in `.env` file according your system.
- In terminal use the command `docker build -f Dockerfile -t nyxtechnology/automessage .` to build the automessage in 
  your system from dockerfile
- In docker/php-apache use the command `docker-compose up` to initialize docker containers