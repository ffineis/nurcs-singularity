Use: internal,external

# Recipe files

If and when a user or Northwestern IT needs to build a new container (for example, if the container is not being hosted on Quest), it's not difficult to create a new container, upload it to the user's home directory on Quest, and use the container there. Singularity [recipe files](https://www.sylabs.io/guides/2.5.1/user-guide/container_recipes.html?highlight=recipe) are the instructions that tell Singularity the exact specifications of how to build your new container.

Authoring new containers on your own machine requires two things:

1. Singularity must be installed on your machine
	- For Linux machines, installation is simple. Follow the directions [here](http://singularity.lbl.gov/install-linux).
	- Singularity cannot be installed directly on a Mac OS or Windows machine. You must install virtual machine hosting software to spin up a virtual machine running a Linux OS and then install Singularity in that VM. Fortunately, there is a Singularity-enabled virtual machine hosted by [Vagrant](https://en.wikipedia.org/wiki/Vagrant_(software)), a VM-management software. Directions for how to use Vagrant to use Singularity: [Mac](http://singularity.lbl.gov/install-mac) and [Windows](http://singularity.lbl.gov/install-windows)
2. You must have `sudo` access on your machine (i.e. administrator-level privileges)

Once you have authored a recipe file, you can build a new container from it:

```bash
> sudo singularity build [container name].simg [recipe file]
```


## Anatomy of a recipe file

### Header
This goes at the top of the file. Use this to define the base operating system you would like your container to be comprised of - that is, it defines a starting point for your container. Most of the time, this would probably be some sort of Linux specification, but you can also use this section to start building from on top of a Docker image. The header is usually just two lines; one line is `Bootstrap: [host]` and the second line is `From: [image source on host]`

For example, many containers start like this:

```bash
Bootstrap: docker
From: ubuntu:16.04
```

This tells Singularity to start building using a basic Ubuntu 16.04 (Ubuntu Xenial Xerus) container.

### Sections
Now comes the heart of the recipe file - the sections. The sections define everything from software to install to environment variables to how the user can interact with the container once its built.

Check out [this Singularity container for R](https://www.singularity-hub.org/containers/2279) for an example of a recipe file with most of the "bells and whistles" Singularity offers.

Below are the possible sections you can have in your recipe file

- `%setup`
- `%files`
- `%post`
- `%test`
- `%labels`
- `%environment`
- `%runscript`
- `%help`
- `app`-related:
	- `%apprun`
	- `%applabels`
	- `%appinstall`
	- `%appenv`
	- `%apphelp`

#### `%setup`
This is the first of only two sections of the recipe file where the host OS will be able to have any access during the build process. For example, if you need variables from the host, you could dump them to a text file, copy that file in the `%files` section later on, and set them in the `%post` or `%environment` section. This section is executed prior to all other sections.

In all honesty, you should avoid using the `%setup` section as much as possible, because it inherently means that you're using things specific to your own machine in order to build what is supposed to be a portable container. This section was only made available in more recent Singularity releases, most likely because it is contrary to the purpose of Singularity.

#### `%files`
This section is run second. It's for copying files from the host machine into the container. For example, if you need the file `python_test.py` to test whether the container works correctly, maybe you want to copy `python_test.py` to the `/opt` directory in the container's Linux file system:

```bash
%files
	python_test.py /opt
```

#### `%post`
This section will likely be the bulk of the recipe file. Because `singularity build` must be run via `sudo`, everything in this section will be executed as if it were an administrator installing into a fresh virtual machine.

For example, if you wanted to install Python 3 in an Ubuntu container, you would run

```bash
%post
	apt-get install python3-dev
```

is run as an administrator. Use this section to install the contents of your application's software.

**Note** that the `%post` section is the best place to define symbolic links with `ln -s`, as this command is typically used to write in /bin, a read-only directory to anyone but root.

#### `%test`
When the container is finished building, the commands specified in this section will execute from within the container so as to test the new container's capabilities. It's best practices to run some sort of test commands to ensure that the container works as intended.

For example, if you wanted to make sure that you had the [`pandas` Python package](https://pandas.pydata.org/) installed correctly, your `%test` section would look like this:

```bash
%test
	python -c "import pandas"
```

#### `%labels`
Put author contact information, version number, and other random metadata here.

#### `%environment`
Establish **run-time** environment variables here. Run-time variables are available when using `singularity run`, `shell`, or `exec`, but **not during build-time**.

Environment variables established in the `%environment` section get written to a file `/.singularity.d/env/90-environment.sh` in the container that gets sourced upon run-time.

You can also export environment variables from the `%post` section like this:

```bash
%post
    echo 'export VARIABLE_NAME=VARIABLE_VALUE' >>$SINGULARITY_ENVIRONMENT
```

Variables that were exported during `%post` get written to a file `/.singularity.d/env/91-environment.sh` and sourced at run-time. Since 91 > 90, the variables in `%post` take precedence over those in `%environment`.

You can also set or override specific environment variables at run time from the command line with a rather gross-looking convention: `SINGULARITYENV_[variable name]`. For example, if you want the variable `TMP` referencing `$HOME/tmp`, you can make it available to you while running a container when run like this:

```bash
> SINGULARITYENV_TMP=$HOME/tmp singularity exec [container]
```

**Note** that there are issues exporting `$PATH` to the container like this. Read the [Singularity documentation](http://singularity.lbl.gov/docs-environment-metadata) for how to prepend, append to, or override the `$PATH` in a container.


#### `%runscript`
These commands are invoked when the user calls `singularity run [container]`.

Using `@` to catch all CLI arguments, the container can be used to expose directly to the user the software you've installed within the container.

For example:
```bash
%runscript
  exec R "$@"
```

lets the user call the container as if it were the `R` command in a terminal that had R installed.

#### `%help`
Write helpful notes here on how to interact with your container, not code.


#### `%app...`
Oftentimes containers are designed to be used as individual software packages themselves, surfacing to the users directly the functionality of the software you've installed in the container.

For example, the [R container](https://www.singularity-hub.org/containers/2279) mentioned previously exposes the standard `R` software entrypoints `R` and `Rscript` to the user. In this way, the user can execute .R scripts as if they had `R` or the `Rscript` command line utility installed all along (even if they don't).

```bash
%apprun R
  exec R "$@"

%apprun Rscript
  exec Rscript "$@"
```

Note that each `%apprun` section contains the app name that defines app-like functionality from this container. So, this container has two apps, `R` and `Rscript`.

Now users can `run` this single container in two ways:

1. `singularity run --app R container.simg -e "for(i in 1:10){print(i)}"` is the same as if the user had called `> R -e "for(i in 1:10){print(i)}"` had they had R installed.

2. `singularity run --app Rscript container.simg some_script.R`

Of course, omitting the `--app` flag with `singularity run` will still invoke the containers `%runscript` section.

The other `%app`-prefixed sections - `%applabels`, `%appinstall`, and `%appenv` - are just app-specific versions of `%labels`, `%post` and `environment` but specific to an individual application.


### Recipe file naming conventions
There are several conventions for naming the recipe file itself. 

Recipe files are typically just named `Singularity`. For [automated container builds](https://github.com/singularityhub/singularityhub.github.io/wiki/Build-A-Container) on Singularity Hub, the recipe files are named `Singularity.[tag illustrating purpose of container]`. In older Singularity releases, recipe files seemed to have the extention `.def`. To be honest, the only convention that really makes sense is `[purpose of container]_recipe.def`, but recipe files are at the end of the day, simply text files with special comments like `%post` and `%files`.


