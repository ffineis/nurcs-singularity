Use: internal,external

# Bootstrapping your recipe file with a template
In the event that your needs are not met through an existing Singularity container on Quest, Singularity Hub, or via a Docker image, you'll need to create a new Singularity container with a Singularity recipe file. You can read more about the structure and components of a recipe file in our post or on [Singularity's documentation on the subject](http://singularity.lbl.gov/docs-recipes).

When it comes to writing this recipe, you need not start from scratch. We've built a Singularity template files to build containers that will come with some of the most common command line and data science utilities. Edit them to your liking, build them into containers, and upload them on to Quest to get up and running with a container best suited for your needs.

Since `#` symbols are used for comments in Singularity recipe files, just un-comment lines to have them execute while building a container.

#### Creating + testing containers: best practices
Once you have made edits to a template recipe file, you'll build the container on a machine where you have `sudo` access. It is recommended that you first create a [*writable* container](https://singularity.lbl.gov/docs-build-container#--writable), enter into the container with `singularity shell`, and test that the container works as intended. Once verified, create a "production" container by creating a duplicate, but "un-writable" container:

```bash
$ sudo singularity build [container name] [writable container name]
```


## Templates

### Linux Ubuntu

TO INSTALL:
- command line utilities
    + curl
    + wget
    + vim
    + awk
    + git

Uncomment lines to install any of the following:
- R (most recent version)
- Useful R packages
- python2 and python3
- Conda (python package manager)
- pip (another python package manager)
- Useful python packages
- Linuxbrew (Homebrew for Linux)

### Alpine Linux

### Postgres

### MySQL

### PHP + Apache

### Biobakery tools
