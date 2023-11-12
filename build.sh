#!/usr/bin/env bash

docker buildx install

docker build -t bilibili-livestream-reminder-complier .

docker run --rm \
    -e USER_ID=$UID \
    -e GROUP_ID=$GID \
    --mount type=bind,src=$PWD,dst=/code \
    bilibili-livestream-reminder-complier
