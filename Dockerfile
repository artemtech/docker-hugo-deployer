FROM alpine

ARG HUGO_VERSION
ARG PLATFORM
ENV HUGO_VERSION=${HUGO_VERSION:-0.112.3}
ENV PLATFORM=${PLATFORM:-amd64}
ENV DEPLOY_TYPE=local
ENV DEPLOY_DESTINATION=/var/www/html/
ENV DEPLOY_PASS_FILE=/root/passfile
ENV KIND=build
ENV WORKING_DIR=/src

WORKDIR $WORKING_DIR

RUN apk add rsync openssh-client --no-cache \
    && wget -O hugo.tar.gz https://github.com/gohugoio/hugo/releases/download/v${HUGO_VERSION}/hugo_${HUGO_VERSION}_linux-${PLATFORM}.tar.gz \
    && tar xf hugo.tar.gz \
    && chmod +x hugo \
    && cp hugo /usr/bin/hugo \
    && rm -rf *

RUN echo $'#!/bin/ash \n\
cek=$(env | grep CI_) \n\
if [[ $? -eq 0 ]]; then \n\
WORKING_DIR="$CI_PROJECT_DIR" \n\
fi \n\
set -ex \n\
cd $WORKING_DIR \n\
if [[ $KIND == "build" ]]; then\n\
    /usr/bin/hugo \n\
else \n\
    DEPLOY_ARGS=""\n\
    if [[ "$DEPLOY_TYPE" == "local" ]]; then\n\
        DEPLOY_ARGS=""\n\
    else\n\
        DEPLOY_ARGS=--rsh="ssh -o StrictHostKeyChecking=false -p ${DEPLOY_PORT:-22}"\n\
    fi\n\
    rsync --progress --delete "${DEPLOY_ARGS}" -avz public/ "${DEPLOY_DESTINATION}"\n\
fi' \
> /usr/bin/hugo-builder


RUN chmod +x /usr/bin/hugo-builder
    
VOLUME /src

CMD /usr/bin/hugo-builder 
