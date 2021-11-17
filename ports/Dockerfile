FROM debian:buster-20211011

COPY ./install-deps ./
RUN DEBIAN_FRONTEND=noninteractive \
    && bash ./install-deps \
    && rm -rf /var/lib/apt/lists/*