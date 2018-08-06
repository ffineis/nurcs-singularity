Use: internal,external

# Bootstrapping your recipe file with a template
In the event that your needs are not met through an existing Singularity container on Quest, Singularity Hub, or via a Docker image, you'll need to create a new Singularity container with a Singularity recipe file. You can read more about the structure and components of a recipe file in our post or on [Singularity's documentation on the subject](http://singularity.lbl.gov/docs-recipes).

When it comes to writing this recipe, you need not start from scratch. We have written Singularity template files to use as starting points for users to build containers with a particular purpose. Edit them to your liking, build them into containers with `sudp singularity build`, and upload them to Quest to get up and running with a container best suited for your needs.

The template recipe files are located in the [NU Research Computing Services Singularity repository](https://github.com/ffineis/nurcs-singularity) in the `templates` directory.

Since `#` symbols are used for comments in Singularity recipe files, simply un-comment lines to have them execute while building a container.

#### Creating + testing containers: best practices
Once you have made edits to a template recipe file, you'll build the container on a machine where you have `sudo` access. It is recommended that you first create a [*writable* container](https://singularity.lbl.gov/docs-build-container#--writable), enter into the container with `singularity shell`, and test that the container works as intended. Once verified, create a "production" container by creating a duplicate, but "un-writable" container:

```bash
$ sudo singularity build [container name] [writable container name]
```


## Templates for containers

### Linux (`/templates/linux.recipe`)
First, choose the Linux distribution. The default is Linux Ubuntu 16.04 (Xenial release), and the rest of the template is designed for an Ubuntu container. It is important to note that the `apt-get` package installer tool is the package management command for Linux Ubuntu distributions. Other distributions - for example Alpine Linux or Fedora - may use other package management commands (e.g. `yum` or `apk`).

The distribution image will be bootstrapped from Docker Hub (note line 1) - bootstrapping from Docker is the easiest way to get a container up and running.

The `%post` section is dedicated to installing useful command line utilities such as `git` and `wget`, and important Linux packages that are often required by software you will try to install later on. The first step towards installing any packages or command line utilities is to run

```bash
$ apt-get -y update && apt-get -y upgrade
```

Should you need more libraries or access to more command line utilities, just append them to the `apt-get install` command. Recall that you can join lines with a forward-slash (`\`). Breaking up the list of Linux packages you're trying to install with `\`'s will make your recipe more readable and easier to scan when trying to install packages that are all similarly-named.


### Data Science

Uncomment lines to install any of the following:
- R (most recent version)
- Useful R packages
- python2 and python3
- Conda (python package manager)
- pip (another python package manager)
- Useful python packages
- Linuxbrew (Homebrew for Linux)

### GPU-enabled applications

### Postgres

### MySQL

### PHP + Apache

### Biobakery tools
