# URL crawler – Sample Python application

A simple service to crawl URLs and extracts the HTML `<title>`.

This has two components :

 - a web server, which serves HTTP requests and schedule crawling tasks
 - a worker, which executes crawling tasks

For scheduling asynchronous tasks, this application uses [Celery](https://docs.celeryq.dev/en/stable/), which leverages a message queue like RabbitMQ or Redis.

This repository also includes a sample [`docker-compose`](./docker-compose.yaml) to quickly try out the application.

Docker images are automatically built by GitHub Actions and published here:

 - [ghcr.io/sandhose/tp-siris-service-discovery/web:latest](https://github.com/sandhose/tp-siris-service-discovery/pkgs/container/tp-siris-service-discovery%2Fweb) for the web server
 - [ghcr.io/sandhose/tp-siris-service-discovery/worker:latest](https://github.com/sandhose/tp-siris-service-discovery/pkgs/container/tp-siris-service-discovery%2Fworker) for the worker

### Interesting bits of code

 - The web server: [`app.py`](./app.py)
 - The worker: [`tasks.py`](./tasks.py)
 - The HTML page template: [`templates/index.html`](./templates/index.html)
 - The configuration file, which reads environment variables: [`config.py`](./config.py) 
 - The Dockerfile building both images: [`Dockerfile`](./Dockerfile)
 - The *docker-compose* stack: [`docker-compose.yaml`](./docker-compose.yaml)
