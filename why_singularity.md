# Why Singularity?

Have you ever wished that you had the ability to install new software on Quest? Quest is a high performance computing (HPC) cluster - it's one massive computing resource shared by everyone in the Northwestern computing community. This is known as [multitenancy](https://en.wikipedia.org/wiki/Multitenancy). The typical user does not have `sudo` access to install software at the root level like system administrator, because then everyone would be able to alter everyone else's computing environment.

Consider a non-Quest solution to your problem. You could use a virtual machine (VM) or a cloud-based machine (such as an AWS instance) precisely because with a VM or a cloud solution, you're the admin user. You're the master of your domain, and you can `sudo` install any software you want. It may feel like Quest is your own virtual machine (especially because you `ssh` to log into Quest), but it's not - it's very much everyone else's computer.

A possible resolution to your problem of having to install new software is to check the [Environment Modules](http://modules.sourceforge.net/) available to you on Quest:

```bash
$ module avail
```

For example, if you needed the 2016 Matlab release, you're in luck:

```bash
$ module load matlab/r2016a
$ matlab
```

Read more on the availability of modules on Quest here.

## Docker 

<img src="https://tr1.cbsistatic.com/hub/i/r/2017/03/23/9cf93159-d002-4d3b-b100-c0a49a4a3189/resize/770x/39d767be960faaa34ae565de17219d78/dockernewhero.jpg" width="100px" height="100px">

If your software isn't available in a module, maybe you've heard of [Docker containers](https://bit.ly/1QBLRnC). Docker containers are like lightweight virtual machines that run like applications. You can configure a container however you want, installing anything as if you were the root user like in the case of a VM. Once you build the container, you run it. This makes available to you whatever software was installed in the container. Docker sounds like the perfect solution.

Unfortunately, the problem of `sudo` access still remains. Docker uses the [Docker daemon](https://docs.docker.com/engine/reference/commandline/dockerd/#description) to run and manage containers, and the daemon requires root privileges. Again, Quest users don't have root access, so Docker is not a solution for Quest.

## Singularity 

<img src="https://www.sylabs.io/guides/2.5.1/user-guide/_static/logo.png" width="100px" height="100px">

You can think of [Singularity](https://www.sylabs.io/guides/2.5.1/user-guide/index.html) as just Docker but with containers that run as you, not as root. The main use case is this:

1.	Build a Singularity container on your own laptop
2.	Move it to Quest
3.	Run `load module singularity` on Quest
4.	Run or execute your container to access the software you wanted in the first place.

And it's not just Quest. Any machine that has Singularity installed on it can use your Singularity container. All you need are the correct file permissions on the single Singularity container `.simg` file to use the container on that machine. But possibly the sweetest perk of all is that Singularity adds to Docker - you can use Singularity to run Docker containers, or you can build a new Singularity container built on top of a Docker container and then adds to it. More on this in the Basic Usage post.

