# Nest Docker Template

Not much going on here, just a simple template repo for using NestJS and Docker together. I'll probably expand on it later. The resulting container is currently 101MB.

## Build

You can either build the docker project using `docker` or `docker-compose`

### Docker

The following command builds the Docker image with the label "docker-nest"

```sh
docker build . -t docker-nest
```

Once build you can run it with 

```sh
docker run -p 80:3000 --rm -d --name nest docker-nest
```

This will expose your server on your localhost's port 80 so you can go to `http://localhost` and see the server respond. Also runs in detached mode and will remove the container when it is stopped.

### Docker-Compose

Using `docker-compose` to run the server, all you need is

```sh
docker-compose up -d
```

Which will run the build, and start the server mapping local port 80 ot the container's port 3000.

## Tests

### Docker

You can build the test docker if you'd like with the following command

```sh
docker build -f test.Dockerfile .
``` 

### Docker-Compose

A better idea would be to use the `docker-compose` built for tests specifically.

```sh
docker-compose -f docker-compose.ci.yml up -d
```

Afterwards you can stop the container with

```sh
docker-compose -f docker-compose.ci.yml down
```