# Builders

A Docker image and collection of scripts to create rpm's of different pieces of software

# Usage

```
docker build -t fpm .
docker run --rm -it -v "$(pwd)/vault":/data fpm bash build.bash
```
