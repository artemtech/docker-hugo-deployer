# docker-hugo-deployer
Hugo deploy to your server using rsync

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
    DEPLOY_PASS_KEY: $DEPLOY_PASS_KEY
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
