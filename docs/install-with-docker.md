## Install Docker

You must install Docker on your Host first.

Please follow Docker offical documentation install Docker with your Host OS.

> We suggest you choice **Ubuntu Server** as Host OS.

[https://docs\.docker\.com/install/](https://docs.docker.com/install/)

## Get BookLab

Use `docker pull` to get BookLab Docker image:

```bash
$ docker pull booklab:latest
```

## Install BookLab

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

You need create a path to storage BookLab's database, uploads or log files.

By default recommends you choice `/var/booklbar`:

```bash
$ booklab_root=/var/booklab
$ sudo mkdir -p ${booklab_root} && sudo chown -R `whoami` ${booklab_root}
```

### Start BookLab

Now, just use `docker run` command to start BooLab

```bash
$ booklab_root=/var/booklab
$ docker run --detach \
             --name booklab \
             --publish 443:443 --publish 80:80 \
             --restart always \
             --volume ${booklab_root}/public/system:/home/app/booklab/public/system \
             --volume ${booklab_root}/data/postgresql:/var/lib/postgresql \
             --volume ${booklab_root}/data/redis:/var/lib/redis \
             --volume ${booklab_root}/data/storage:/home/app/booklab/storage \
             --volume ${booklab_root}/log:/home/app/booklab/log \
             --volume ${booklab_root}/tmp:/home/app/booklab/tmp \
             booklab:latest
```

after run that command, you can use `docker logs booklab` to checkout the logs.


```bash
$ docker logs booklab
```

Or use `docker ps` to checkout processes:

```bash
$ docker ps | grep booklab
```

## Update BookLab

We will continue upgrade BookLab, you can upgrade it by:

```
$ docker pull booklab:lastest
```

And then, recreate Docker Container:

```
$ docker stop booklab
$ docker rm booklab
$ booklab_root=/var/booklab

$ docker run --detach \
             --name booklab \
             --publish 443:443 --publish 80:80 \
             --restart always \
             --volume ${booklab_root}/public/system:/home/app/booklab/public/system \
             --volume ${booklab_root}/data/postgresql:/var/lib/postgresql \
             --volume ${booklab_root}/data/redis:/var/lib/redis \
             --volume ${booklab_root}/data/storage:/home/app/booklab/storage \
             --volume ${booklab_root}/log:/home/app/booklab/log \
             --volume ${booklab_root}/tmp:/home/app/booklab/tmp \
             booklab:latest
```
