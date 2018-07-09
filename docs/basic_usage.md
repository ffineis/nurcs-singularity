Use: internal, external

# Basic Usage

There are only four Singularity commands you're ever likely ever to use. If you're not `build`ing your own containers, you can make that just three commands.

Let's suppose you're on Quest logged in as the user `test_user`. You're working on a project in the `~/myproject` directory, and you've uploaded a Singularity container from your laptop (building a Singularity container from scratch and uploading it to Quest is definitely not your only option for using containers, but more on that later). Suppose your directory tree looks like this:

```
|-- home
| |-- test_user
|   |-- myproject
|     |-- cool_script.py
|     |-- intense_script.m
|     |-- some_data.csv
|     |-- container.simg
|     `-- container_recipe.def
```

and further, suppose you just ran `cd ~/myproject`, so we're in `/home/test_user/myproject`.

### `singularity shell singularity_files/container.simg`

This is as if you just "logged in" to the Singularity container, as if it was a virtual machine. When you use `shell`, you're using the Singularity container's OS's default shell, which is the Bourne shell (i.e. bash) by default.

Let's suppose that `container.simg` is just a basic, basic Linux Ubuntu container. When you `shell` into `container.simg`, you're running an Ubuntu OS:

```
Singularity container.simg:~/> ls /
bin   dev	   etc	 lib	media  opt   root  sbin		srv  tmp  var
boot  environment  home  lib64	mnt    proc  run   singularity	sys  usr

Singularity container.simg:~/> cat /etc/os-release | grep "^NAME"
NAME="Ubuntu"
```

If you wanted to run the `cool_script.py` Python script, the container must have Python installed, along with all of the Python dependencies that `cool_script.py` needs. If you do, then you shouldn't have any trouble running something like this:

```
Singularity container.simg:~/> python cool_script.py
```

The only caveat when it comes to `shell` is that your reading and writing priviledges are different. Not all of the files available to you on Quest outside of the Container will be accessible to you from within the container; it depends on which of your outside directories are `bound` to the container. Directory binding is very important, so make sure to read the Binding post. You also will not be able to edit or write within a directory that is not bound to the outside world. For example, you'll likely get an error if you try to create the file "hello_world.txt" in the root directory.

```
Singularity container.simg:~/> echo "hello_world" >> /hello_world.txt
bash: /hello_world.txt: Read-only file system
```

You can't fix the reading-files problem without binding the correct directories, but you can fix the writing-files problem by having built `container.simg` with the `--writable` flag during the `build` process and then proceeding to `run` the container with the `--writable` flag as well. Read more about writable containers from the [Singularity documentation](https://www.sylabs.io/guides/2.5.1/user-guide/build_a_container.html?highlight=writable#creating-writable-images-and-sandbox-directories).

### `singularity run singularity_files/container.simg`
This will execute the container as if it were some sort of application. When the container is built from a Singularity [recipe file](https://www.sylabs.io/guides/2.5.1/user-guide/container_recipes.html?highlight=recipe), you can define a ["%runscript" section](https://www.sylabs.io/guides/2.5.1/user-guide/quick_start.html#running-a-container) - a set of commands that will execute every time you run `singularity run ...`

During the container `build` process, the instructions in the "%runscript" section will be dumped into the file `/singularity` (within the container). When you `run` the container, it's the same thing as if you had `shell`'ed into the container and run `sh /singularity`.

For example, suppose the recipe file used to `build` our container `container.simg` contained a `%runscript` section that looked like this:

```bash
%runscript
    echo "heyyyyy ${USER}"
```

When `run` the container, the message `heyyyyy test_user` will print to the console.

You can also use `@` to reference arguments passed to `singularity run` that get passed directly to the runscript so that the container can take parameters from the command line. For example, this [R Singularity container](https://www.singularity-hub.org/apps/335) accepts a user's .R file and runs it:

```bash
%apprun Rscript
exec Rscript "${@}"
```

The `%apprun` section heading has to do with the application interfacing you can use to define the behavior of a container when used as an application. More on this later, but the [Singularity documentation on hosting multiple applications within a single container](https://www.sylabs.io/guides/2.5.1/user-guide/container_recipes.html#apps) is very helpful.


### `singularity exec singularity_files/container.simg [COMMAND]`
This will execute whatever `COMMAND` you want, but using the resources available to us from within the container. For example, perhaps we have Matlab installed in `container.simg`, but not on the host machine. Execute `intense_script.m` using the Matlab installed in the container like this:

```bash
$ cd myproject
$ singularity exec container.simg matlab -nodesktop -nosplash -r "intense_script; exit;"
```

Singularity's `exec` command is the intented entrypoint for the majority of users' interactions with Singularity on the HPC. More on this in the Workflow post.



### `singularity build ... ...`
You're free to `build` new Singularity containers if you can't find something on Quest, [Singularity Hub](https://singularity-hub.org/), or [Docker Hub](https://hub.docker.com/). Note that you need `sudo` privileges to run `singularity build`, so you'll have to build the container on your personal computer or from within another environment where you can `sudo`.

You have a few choices for sourcing the container build.

1. Use your own [recipe file](https://www.sylabs.io/guides/2.5.1/user-guide/container_recipes.html?highlight=recipe)
2. Pull a container from Singularity Hub (prefix source with `shub://`)
3. Pull a Docker image from Docker Hub (prefix source with `docker://`)


### Using a recipe file
It's easy to get started writing your own recipe file, but there is admittedly a lot to say. Please refer to the post on subject or to the [Singularity documentation](https://www.sylabs.io/guides/2.5.1/user-guide/container_recipes.html?highlight=recipe). To build `container.simg` with the recipe file `container_recipe.def`, run

```bash
$ sudo singularity build container.simg container_recipe.def
```


### Building with [Singularity Hub](https://singularity-hub.org/) or Docker images from [Docker Hub](https://hub.docker.com/)
There's no need to constantly reinvent the wheel - there's whole world of Singularity containers and Docker images that other people already maintain for you. For example, if you want to run a PostgreSQL 9.5 database from a Singularity container using an Ubuntu OS, just build the container using the PostgreSQL image from Docker Hub. This saves you the hassle of having to write a Singularity recipe that `apt-get install`s everything, sets library paths, edits .conf files, etc.

```bash
$ sudo singularity build postgres.simg docker://postgres:9.5
```

To pull a Singularity container from Singularity Hub, just change the URI to `shub://`. For example:

```bash
$ sudo singularity build rstudio.simg shub://kalebabram/singularity_rstudio:latest
```

