# docker-hugo-deployer
Hugo deploy to your server using rsync

## configs
| environment name | value | default|
|---|---|---|
|`KIND`|`build` or `deploy`|`build`|
|`DEPLOY_TYPE`|`local` or `ssh`|`local`|
|`DEPLOY_DESTINATION`|`/var/www/html/`|`/var/www/html/`|
|`DEPLOY_PORT`|`22`|`22`|
|`SSH_KEY`|`base64 of your ssh key content`|none|

if using `DEPLOY_TYPE=ssh`, set `DEPLOY_DESTINATION` to `username@host-target:/your/destination/path`

## usage in gitlab-ci
```
stages:
  - build
  - deploy

variables:
  GIT_SUBMODULE_STRATEGY: recursive

build-and-test:
  stage: build
  image: artemtech/hugo-deployer
  variables:
    KIND: build
  script:
  - hugo-builder
  artifacts:
    paths:
    - public

go-to-production:
  stage: deploy
  image: artemtech/hugo-deployer
  when: manual
  variables:
    KIND: deploy
    DEPLOY_TYPE: ssh
    SSH_KEY: $SSH_DEPLOY_KEY
  before_script:
    - mkdir -p ~/.ssh
    - 'which ssh-agent || ( apk add --update openssh )'
    - eval "$(ssh-agent -s)"
    - echo "${SSH_KEY}" | tr -d ' ' | base64 -d | ssh-add -
  script:
    - hugo-builder

```
