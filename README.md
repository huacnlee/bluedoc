# BlueDoc

[![Build Status](https://travis-ci.org/thebluedoc/bluedoc.svg?branch=master)](https://travis-ci.org/thebluedoc/bluedoc)

## Development

### Setup with docker

First you must have docker services and start it then 

`$ docker-compose up dev` 

That all depends softwares have ready

And you should rename project root file `.env.example` to `.env`
 
```bash
$ cd bluedoc && mv .env.example .env
```
You can change `.env` configuration to any what u need. More `.env` you can find at [here](https://github.com/bkeepers/dotenv)

Next

```bash
$ yarn install
$ bundle install
$ rails db:create db:migrate
$ rails db:seed
$ rails s
$ yarn start #other termal tab
$ sidekiq -C ./config/sidekiq.yml #other termal tab if u need
```

Now u can open brower and visit [bluedoc](http://localhost:3000)

More configuration you can look from ***docker-compose.yml***

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

Default admin user: ***admin@bluedoc.io*** password: ***123456***

```bash
$ rails g scaffold_controller admin/repository slug:string name:string user:references description:string
```
