FROM golang:1.19-bullseye as builder
# FROM quay.io/ceph/ceph:v17 
# ENV CEPH_VERSION 17.2.5
RUN apt-get update && apt-get install -yq software-properties-common wget gnupg \
    && wget -q -O- 'https://download.ceph.com/keys/release.asc' | apt-key add - \
    && apt-add-repository "deb https://download.ceph.com/debian-quincy/ focal main" \
    && apt-get update && apt-get install -yq libcephfs-dev librbd-dev librados-dev \
    && rm -rf /var/lib/apt/lists/*
COPY go.* main.go /go/src/docker-volume-rbd/
COPY lib /go/src/docker-volume-rbd/lib
WORKDIR /go/src/docker-volume-rbd
RUN go build -tags ceph_preview

FROM debian:bullseye
RUN apt-get update && apt-get install -yq software-properties-common wget gnupg \
    && wget -q -O- 'https://download.ceph.com/keys/release.asc' | apt-key add - \
    && apt-add-repository "deb https://download.ceph.com/debian-quincy/ focal main" \
    && apt-get update && apt-get install -yq libcephfs-dev librbd-dev librados-dev \
    && rm -rf /var/lib/apt/lists/*
COPY --from=builder /go/src/docker-volume-rbd/docker-volume-rbd /usr/bin/docker-volume-rbd
CMD ["/usr/bin/docker-volume-rbd"]