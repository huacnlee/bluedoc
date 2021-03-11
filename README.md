# BlueDoc

[![Test](https://github.com/huacnlee/bluedoc/workflows/Test/badge.svg)](https://github.com/huacnlee/bluedoc/actions)

## Development

Setup base development env have two approach

Default admin user: ***admin@bluedoc.io*** password: **_123456_**

### Setup with docker

First you must have docker services and start it and then

`$ docker-compose up dev`

That all depends softwares have ready

Next

```bash
$ yarn install
$ bundle install
$ POSTGRES_USER=postgres POSTGRES_HOST=localhost rails db:create db:migrate
$ rails s
$ yarn start #other termal tab
$ sidekiq -C ./config/sidekiq.yml #other termal tab if u need
```

Now u can open brower and visit [bluedoc](http://localhost:3000)

More configuration you can look from **_docker-compose.yml_**

### Setup with local machine

You need install depends softwares first:

```bash
$ brew install node imagemagick postgresql elasticsearch redis
$ brew cask install wkhtmltopdf
```

Setup the default ENV vars to open all features:

```
export LDAP_HOST=localhost

export OMNIAUTH_GOOGLE_CLIENT_ID=
export OMNIAUTH_GOOGLE_CLIENT_SECRET=

export OMNIAUTH_GITHUB_CLIENT_ID=
export OMNIAUTH_GITHUB_CLIENT_SECRET=

export OMNIAUTH_GITLAB_CLIENT_ID=
export OMNIAUTH_GITLAB_CLIENT_SECRET=
export OMNIAUTH_GITLAB_API_PREFIX=
```

Start development server:

- `yarn start` - to start webpack dev server.
- `rails s` - to start rails

```bash
$ yarn start
```

In other Termal tab:

```bash
$ rails s
```

## Install plantuml-service

plantuml-service for generate PlantUML image

https://github.com/bitjourney/plantuml-service

```bash
$ brew install bitjourney/self/plantuml-service
$ brew services start bitjourney/self/plantuml-service
```

### Generate Admin

```bash
$ rails g scaffold_controller admin/repository slug:string name:string user:references description:string
```

## Deployment

```bash
#!/usr/bin/env sh
docker stop bluedoc
docker rm bluedoc

bluedoc_root=/tmp/bluedoc
mkdir -p /tmp/bluedoc/data
touch ${bluedoc_root}/data/production.env
docker run --detach \
           --name bluedoc \
           --publish 443:443 --publish 80:80 \
           --restart always \
           --volume ${bluedoc_root}/postgresql:/var/lib/postgresql \
           --volume ${bluedoc_root}/redis:/var/lib/redis \
           --volume ${bluedoc_root}/elasticsearch:/usr/share/elasticsearch/data \
           --volume ${bluedoc_root}/storage:/home/app/bluedoc/storage \
           --volume ${bluedoc_root}/data:/home/app/bluedoc/data \
           --volume ${bluedoc_root}/log:/home/app/bluedoc/log \
           --volume ${bluedoc_root}/tmp:/home/app/bluedoc/tmp \
           --env-file ${bluedoc_root}/data/production.env \
           bluedoc/bluedoc:latest
```
