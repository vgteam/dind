# Docker-in-Docker

This recipe lets you run Docker within Docker, on a reasonably modern Ubuntu base.

![Inception's Spinning Top](spintop.jpg)

There is only one requirement: your Docker version should support the
`--privileged` flag.


## A word of warning

If you do *not* need your child containers to be actual children (i.e. you don't need to mount any parent paths in the child), *or* if you are happy with Alpine in your container, you should use `docker:dind` instead. See also [jpetazzo's blog post on nesting Dockers for CI](http://jpetazzo.github.io/2015/09/03/do-not-use-docker-in-docker-for-ci/).


## Quickstart

Run Docker-in-Docker and get a shell where you can play, with docker daemon logs
going into `/var/log/docker.log`:
```bash
docker run --privileged -t -i quay.io/vgteam/dind
```

Run Docker-in-Docker and get a shell where you can play, and docker daemon logs
to stdout:
```bash
docker run --privileged -t -i -e LOG= quay.io/vgteam/dind
```



### Daemon configuration

You can use the `DOCKER_DAEMON_ARGS` environment variable to configure the
docker daemon with any extra options:
```bash
docker run --privileged -d -e DOCKER_DAEMON_ARGS="-D" quay.io/vgteam/dind
```

## It didn't work!

If you get a weird permission message, check the output of `dmesg`: it could
be caused by AppArmor. In that case, try again, adding an extra flag to
kick AppArmor out of the equation:

```bash
docker run --privileged --lxc-conf="lxc.aa_profile=unconfined" -t -i quay.io/vgteam/dind
```

If you get the warning:

````
WARNING: the 'devices' cgroup should be in its own hierarchy.
````

When starting up dind, you can get around this by shutting down docker and running:

````
# /etc/init.d/lxc stop
# umount /sys/fs/cgroup/
# mount -t cgroup devices 1 /sys/fs/cgroup
````

If the unmount fails, you can find out the proper mount-point with:

````
$ cat /proc/mounts | grep cgroup
````

## How It Works

The main trick is to have the `--privileged` flag. Then, there are a few things
to care about:

- cgroups pseudo-filesystems have to be mounted, and they have to be mounted
  with the same hierarchies than the parent environment; this is done by a
  wrapper script, which is setup to run by default;
- `/var/lib/docker` cannot be on AUFS, so we make it a volume.

That's it.


## Important Warning About Disk Usage

Since AUFS cannot use an AUFS mount as a branch, it means that we have to
use a volume. Therefore, all inner Docker data (images, containers, etc.)
will be in the volume. Remember: volumes are not cleaned up when you
`docker rm`, so if you wonder where did your disk space go after nesting
10 Dockers within each other, look no further :-)


## Which Version Of Docker Does It Run?

Outside: it will use your installed version.

Inside: the Dockerfile will retrieve the latest `docker` binary from
https://get.docker.io/; so if you want to include *your* own `docker`
build, you will have to edit it. If you want to always use your local
version, you could change the `ADD` line to be e.g.:

    ADD /usr/bin/docker /usr/local/bin/docker


## Can I Run Docker-in-Docker-in-Docker?

Yes. Note, however, that there seems to be a weird FD leakage issue.
To work around it, the `wrapdocker` script carefully closes all the
file descriptors inherited from the parent Docker and `lxc-start`
(except stdio). I'm mentioning this in case you were relying on
those inherited file descriptors, or if you're trying to repeat
the experiment at home.

[kojiromike/inception](https://github.com/kojiromike/inception) is
a wrapper script that uses dind to nest Docker to arbitrary depth.

Also, when you will be exiting a nested Docker, this will happen:

```bash
root@975423921ac5:/# exit
root@6b2ae8bf2f10:/# exit
root@419a67dfdf27:/# exit
root@bc9f450caf22:/# exit
jpetazzo@tarrasque:~/Work/DOTCLOUD/dind$
```

At that point, you should blast Hans Zimmer's [Dream Is Collapsing](
http://www.youtube.com/watch?v=imamcajBEJs) on your loudspeakers while twirling
a spinning top.
