Use: internal, external

# Authenticating for Private Docker Registries

Possibly the most impactful consequence of using Singularity on Quest is that it indirectly gives users access to Docker images, images that may or may not be available in public registries (registries are for Docker what organizations for GitHub). 

In pulling Docker container, you use the URI template

> docker://<registry>/<namespace>/<repo_name>:<repo_tag>`

Most often the registry is just `docker.io`, a publicly available registry.

Not all Docker images are public, and you might need a username and password to pull the contents of a particular registry for your Singularity container. There are two options, as outlined in [Singularity's documentation on authentication](https://www.sylabs.io/guides/2.5/user-guide/singularity_and_docker.html#custom-authentication), which is your best resource on this subject.

Option 1 (not for publicly shared recipe files): include `Username`, `Password`, and the Docker registry in the recipe file header:

```
From: Docker
Username: [your username acquired from registry owner]
Password: [your password acquired from registry owner]
Registry: <something.io>
From: <namespace>/<repo_name>:<repo_tag>
```

Do *not* use this option if you plan to commit the recipe file to a public repository.

Option 2: export the `SINGULARITY_DOCKER_USERNAME` and `SINGULARITY_DOCKER_PASSWORD` in your environment, and then pull the image from the private registry with `singularity pull`, using the full Docker URI (because `docker.io` is the assumed default).


## What to do if authentication fails: `docker2singularity`

There's no guarantee that the 3rd party hosting the private Docker registry you may be attempting to pull from will have a working API, and therefore a working interface with `singularity pull`. For an example, see the Nvidia containers below.

In this case, resort to `docker2singularity`(https://github.com/singularityware/docker2singularity), an uninstalled tool that (magically) pulls and converts Docker containers into Singularity containers. Note that you in order to run `docker2singularity`, you will need to run it on your own machine, where you will need to have [Docker installed](https://docs.docker.com/install/#supported-platforms) installed! This is not a solution to be run on Quest (where Docker is unavailable).

1. Install Docker on your local machine.
2. Log into the registry (from the command line) with the `docker login` utility:
```docker login <registry name>.io```

3. Use `docker2singularity` to pull a Docker container, change it into a Singularity container, and save it to your machine:
```
docker run \
-v /var/run/docker.sock:/var/run/docker.sock \
-v [path/where/you/want/to/save/container]:/output \
--privileged -t --rm \
singularityware/docker2singularity \
[<registry>/<namespace>/<repo_name>:<repo_tag>]
```

4. Upload container to Quest.


## Example: Nvidia Docker containers
As part of their "Nvidia GPU Cloud" project, Nvidia offers a large set of GPU-enabled Docker containers in a private registry [nvcr.io](https://docs.nvidia.com/ngc/). The containers are primarily geared towards machine learning applications, with containers for most deep learning programming frameworks. Instead of having to build a new deep learning container if or when GPU drivers get updated on a Quest, or if you join a new GPU allocation - just pull a container from the registry with a CUDA release compatible with the installed drivers.

Unfortunately, pulling with `singularity` is likely not going to work, as you are likely to get authentication errors, even after abiding by Singularity's documented practices. Instead, pull the container with `docker` and convert it into a Singularity container:

```
docker run \
-v /var/run/docker.sock:/var/run/docker.sock \
-v $HOME/containers \
--privileged -t --rm \
singularityware/docker2singularity \
nvcr.io/nvidia/tensorflow:18.08-py3
```











