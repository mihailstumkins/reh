FROM ubuntu:16.10

RUN apt-get -qq update
RUN apt-get -qq -y install curl

RUN curl -sL https://apt.vapor.sh | bash

RUN apt-get -qq -y install swift vapor
RUN curl -sL check.vapor.sh | bash

WORKDIR /app

ENTRYPOINT /app/docker-entrypoint.sh
