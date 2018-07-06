# Basic Usage

There are only four Singularity commands you're ever likely ever to use. If you're not `build`ing your own containers, you can make that just three commands.

Let's suppose you're on Quest logged in as the user `test_user`. You're working on a project in the `~/myproject` directory, and you've uploaded a Singularity container from your laptop (building a Singularity container from scratch and uploading it to Quest is definitely not your only option for using containers, but more on that later). Suppose your directory tree looks like this:

```
|-- home
| |-- test_user
|   |-- myproject
|     |-- cool_script.py
|     `-- some_data.csv
|   |-- singularity_files
|     `-- container.simg
```

and further, suppose you just ran `cd ~`, so we're in `/home/test_user`.

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
Singularity container.simg:~/> python myproject/cool_script.py
```

The only caveat when it comes to `shell` is that your reading and writing priviledges are different. Not all of the files available to you on Quest outside of the Container will be accessible to you from within the container; it depends on which of your outside directories are `bound` to the container. Directory binding is very important, so make sure to read the Binding post. You also will not be able to edit or write within a directory that is not bound to the outside world. For example, you'll likely get an error if you try to create the file "hello_world.txt" in the root directory.

```
Singularity container.simg:~/> echo "hello_world" >> /hello_world.txt
bash: /hello_world.txt: Read-only file system
```

You can't fix the reading-files problem without binding the correct directories, but you can fix the writing-files problem by having built `container.simg` with the `--writable` flag during the `build` process and then proceeding to `run` the container with the `--writable` flag as well. Read more about writable containers from the [Singularity documentation](https://www.sylabs.io/guides/2.5.1/user-guide/build_a_container.html?highlight=writable#creating-writable-images-and-sandbox-directories).

