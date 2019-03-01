## Install Docker

You must install Docker on your Host first.

Please follow Docker offical documentation install Docker with your Host OS.

> We suggest you choice **Ubuntu Server** as Host OS.

[https://docs\.docker\.com/install/](https://docs.docker.com/install/)

## Get BlueDoc

Use `docker pull` to get BlueDoc Docker image:

```bash
$ docker pull bluedoc/bluedoc:latest
```

## Install BlueDoc

### Config your custom SECRET_KEY_BASE

**SECRET_KEY_BASE** is use for encrypt the User session or other case that nees encrypting.

> NOTE: Keep SECRET_KEY_BASE in sercet!

```bash
sudo su -c 'echo "export SECRET_KEY_BASE=`openssl rand -hex 32`" > /etc/profile.d/rails-profile.sh'
```

And then exit SSH, and relogin again to test:

```bash
$ echo $SECRET_KEY_BASE
1205f63c89688ce9fde961232251254125034f5ef7b744245794682f63
```

### Initialize volume

You need create a path to storage BlueDoc's database, uploads or log files.

By default recommends you choice `/var/bluedoc`:

```bash
$ bluedoc_root=/var/bluedoc
$ sudo mkdir -p ${bluedoc_root} && sudo chown -R `whoami` ${bluedoc_root}
```

### Start BlueDoc

Now, just use `docker run` command to start BlueDoc

```bash
$ bluedoc_root=/var/bluedoc
$ docker run --detach \
             --name bluedoc \
             --publish 443:443 --publish 80:80 \
             --restart always \
             --volume ${bluedoc_root}/public/system:/home/app/bluedoc/public/system \
             --volume ${bluedoc_root}/data/postgresql:/var/lib/postgresql \
             --volume ${bluedoc_root}/data/redis:/var/lib/redis \
             --volume ${bluedoc_root}/data/elasticsearch:/usr/share/java/elasticsearch/data \
             --volume ${bluedoc_root}/data/storage:/home/app/bluedoc/storage \
             --volume ${bluedoc_root}/fonts:/home/app/bluedoc/fonts \
             --volume ${bluedoc_root}/log:/home/app/bluedoc/log \
             --volume ${bluedoc_root}/tmp:/home/app/bluedoc/tmp \
             bluedoc/bluedoc:latest
```

after run that command, you can use `docker logs bluedoc` to checkout the logs.


```bash
$ docker logs bluedoc
```

Or use `docker ps` to checkout processes:

```bash
$ docker ps | grep bluedoc
```

## Update BlueDoc

We will continue upgrade BlueDoc, you can upgrade it by:

```
$ docker pull bluedoc/bluedoc:latest
```

And then, recreate Docker Container:

```
$ docker stop bluedoc
$ docker rm bluedoc
$ bluedoc_root=/var/bluedoc

$ docker run --detach \
             --name bluedoc \
             --publish 443:443 --publish 80:80 \
             --restart always \
             --volume ${bluedoc_root}/public/system:/home/app/bluedoc/public/system \
             --volume ${bluedoc_root}/data/postgresql:/var/lib/postgresql \
             --volume ${bluedoc_root}/data/redis:/var/lib/redis \
             --volume ${bluedoc_root}/data/elasticsearch:/usr/share/elasticsearch/data \
             --volume ${bluedoc_root}/data/storage:/home/app/bluedoc/storage \
             --volume ${bluedoc_root}/fonts:/home/app/bluedoc/fonts \
             --volume ${bluedoc_root}/log:/home/app/bluedoc/log \
             --volume ${bluedoc_root}/tmp:/home/app/bluedoc/tmp \
             bluedoc/bluedoc:latest
```