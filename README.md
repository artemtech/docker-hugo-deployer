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
|`WORKING_DIR`|`/src`|`/src`|

If using `DEPLOY_TYPE=ssh`, set `DEPLOY_DESTINATION` to `username@host-target:/your/destination/path`.  

If you are using ci/cd service like gitlab-ci or github-action, WORKING_DIR is set to `$CI_PROJECT_DIR`.  

If you are building your site locally, you can bind mount your project to /src inside container, and bind mount your desired destination folder as you defined in DEPLOY_DESTINATION environment. For example:
```bash
# build
docker run --rm -dti -e DEPLOY_TYPE=local \
-e KIND=build \
-e DEPLOY_DESTINATION=/destination \
-v /home/artemtech/hugo-site-src:/src \
-v /home/artemtech/blog:/destination \
artemtech/hugo-deployer

# deploy
docker run --rm -dti -e DEPLOY_TYPE=local \
-e KIND=deploy \
-e DEPLOY_DESTINATION=/destination \
-v /home/artemtech/hugo-site-src:/src \
-v /home/artemtech/blog:/destination \
artemtech/hugo-deployer
```

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
