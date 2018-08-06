Use: internal,external

# Using Singularity on Quest

On Quest, Singularity is installed system-wide, so you will always have access to the `singularity` command.

## Accessing containers

The `singularity` command is always used with a particular container, so you'll need access to the the Singularity container file you want to run/execute/shell into/etc... There are multiple ways to do this.

### Uploading a built image from your local machine
If you have built or downloaded a container on your local machine, you should upload it to Quest (recommended you use Cyberduck or sftp) if you have not already.

Here is an example of using `sftp` to upload the `my_container.simg` container to your home directory on Quest:
```bash
(my-local-machine) sftp [my username]@quest.it.northwestern.edu
<enter password>

put my_container.simg .
```

### Pulling an image from a Singularity Hub collection
[Pull](http://singularity.lbl.gov/docs-pull) a Singularity container maintained on [NU IT's Singularity Hub collection](https://www.singularity-hub.org/collections/1271), a container from any other Singularity Hub collection, or any Docker container available on Docker Hub. It is recommended that you pull containers on a per-job basis to the `$TMPDIR` directory created upon requesting resources from Moab. **Consult the best practices section below.**

For example, to pull the CPU-supported MXNet container into your home directory on Quest, run the following:

```bash
$ export SINGULARITY_PULLFOLDER=$TMPDIR
$ singularity pull shub://ffineis/nurcs-singularity:mxnet_cpu
```

When you pull a container from Singularity Hub or Docker, it will probably come with a long, gross file name. Rename it automatically during the pull with the `--name` flag:

```bash
$ singularity pull --name mxnet_cpu.simg shub://ffineis/nurcs-singularity:mxnet_cpu
```


# Using containers
Your main entrypoints into a Singularity container are `singularity exec`, `singularity shell`, and if your container has been designed to run like an application, `singularity run`.

Recall that `singularity exec` allows you run an arbitrary command from within your container as if it were available to you on your host OS - e.g. if the genomics tool `halla` isn't installed for you on Quest, running `singularity exec my_container.simg halla [args]` runs as though you had `halla` installed. Meanwhile, `singularity shell` is for entering an interactive session within the Singularity container. Therefore, the rule of thumb is this:

- Use `singularity exec` when you're submitting batch jobs to Quest.
- Use `singularity shell` when you're working in an interactive session on Quest.
- `singularity run` can be useful in a batch or interactive setting depending on the application launched from within the container when `run` is called.

## Interactive command line sessions and `singularity shell`
Suppose you do not have the MXNet library installed on Quest, but you have access to the container `mxnet_cpu.simg` with the library installed. Suppose you want to debug your MXNet code in an interactive command line session.

First, request an interactive session on a compute node(s). [Read more on interactive jobs on Quest](https://kb.northwestern.edu/69247#interactive).

```bash
$ msub -I -l nodes=1:ppn=4 -l walltime=01:00:00 -q short -A <allocationid>
$ export SINGULARITY_PULLFOLDER=$TMPDIR
$ singularity pull --name mxnet_cpu.simg shub://ffineis/nurcs-singularity:mxnet_cpu
```

Let's assume that `mxnet_cpu.simg` is in your home directory. "Enter" the container with `singularity shell`, where you have MXNet installed as a Python and R library. **Once you enter the container with `shell`, it's like you're running on a new machine that has the MXNet libraries installed:**

```bash
$ singularity shell mxnet_cpu.simg
Singularity mxnet_cpu.simg:~/> R
> library(mxnet)
> install.packages('mlbench')
> data(Sonar, package="mlbench")
> Sonar[,61] = as.numeric(Sonar[,61])-1
> train.ind = c(1:50, 100:150)
> train.x = data.matrix(Sonar[train.ind, 1:60])
> train.y = Sonar[train.ind, 61]
> test.x = data.matrix(Sonar[-train.ind, 1:60])
> test.y = Sonar[-train.ind, 61]
> mx.set.seed(0)
> model <- mx.mlp(train.x, train.y, hidden_node=10, out_node=2, out_activation="softmax",
                num.round=20, array.batch.size=15, learning.rate=0.07, momentum=0.9,
                eval.metric=mx.metric.accuracy)
```

You can exit the Singularity shell session from the command prompt by typing `exit`.


## Batch jobs: using `singularity exec` in a job submission file
If you want to submit a batch job on Moab via `msub` that leverages a Singularity container, you're either going to use `singularity exec` or `singularity run` (or both).

Suppose we have an .R script called `mxnet_model_builder.R` that uses command line flags (with the R package [`argparse`](https://github.com/trevorld/argparse/blob/master/exec/example.R)) that can train a machine learning model with MXNet and can also send new data through a model and save the predictions:

```bash
$ Rscript mxnet_model_builder.R --train-data training.csv --model truck_model.RDS    # trains and saves a model
$ Rscript mxnet_model_builder.R --test-data test.csv --model ./truck_model.RDS       # executes model on test.csv dataset
```

You can submit a Moab job (in the file `mxnet_modeler_submission.sh`) that trains and tests a model using the MXNet installation in `mxnet_cpu.simg`. Use `singularity shell` followed by a command that you would like to be exectuted from within the container:

```bash
$ cat mxnet_modeler_submission.sh

#!/bin/bash
#MSUB -A <allocation ID>
#MSUB -l walltime=05:00:00
#MSUB -j oe
#MSUB -q normal
#MSUB -N mxnet_modeler
#MSUB -l nodes=2:ppn=16

# Pull the container to a disposable directory.
export SINGULARITY_PULLFOLDER=$TMPDIR
singularity pull --name mxnet_cpu.simg shub://ffineis/nurcs-singularity:mxnet_cpu

# Run the job...
singularity shell mxnet_cpu.simg Rscript mxnet_model_builder.R --train-data ../data/training.csv --model ../models/truck_model.RDS
singularity shell mxnet_cpu.simg Rscript mxnet_model_builder.R --test-data test.csv --model ./truck_model.RDS


$ msub mxnet_modeler_submission.sh
```


#### Binding directories
As a Quest user, you may be part of an allocation that gives you access to a special Quest node. For example, [perhaps you're part of the b1042 genomics nodes](https://www.it.northwestern.edu/research/user-services/quest/genomics.html), and all of your research group's data is located in a directory located at `/projects/b1042/my_PI/cluster_data`. If you refer to the ``


### `singularity run`
Some containers have entrypoints (i.e. interfaces) and are configured to be run like applications. For example, [this container](https://www.singularity-hub.org/containers/2279) has R and the R command line interface tools (e.g. Rscript) installed on it. The `%runscript` section ot the container's recipe file has specified

```bash
%runscript
    exec R "$@"
```

Suppose we pulled this container and named it `base_r.simg`. Then whenever you we `singularity run base_r.simg`, this is the same thing as running the command `R` from the command line. So we could run this:

```bash
$ singularity run base_r.simg -e 'library(dplyr); filter(mtcars, hp >= 100)'
```

This is the same as running `R -e 'library(dplyr); filter(mtcars, hp >= 100)'` on a machine that has R (and the dplyr package) installed. Your container may also be configured to run as multiple types of softwares through [app functionality](https://singularity.lbl.gov/docs-recipes#apps) which may also affect the exact way in which you call `singularity run` to execute your programs.

## Containers + GPUs
Singularity containers can be deployed on GPUs, and can use them to run popular GPU-supported software.

Suppose you have requested an interactive job on a GPU partition on Quest:
```bash

```


## Best practices

### Pulling Singularity containers from Singularity Hub
If you would like to run a container on Quest, we recommend that you pull the container on a per-job basis to the `$TMPDIR` directory created whenever you request resources for a job on Moab. This is a disposable directory. Do this, as opposed to keeping copies of the containers in your `$HOME` directory - container files can get very large, very quickly.

In your job submission script, or from within an interactive Moab session:
1. Run `export SINGULARITY_PULLFOLDER=$TMPDIR`
2. Pull your container. For example, to pull the Biobakery container from NU IT Research Computing Services' Singularity Collection, add this:
```bash
singularity pull --name biobakery.simg shub://ffineis/nurcs-singularity:biobakery
```

Now you will have the container `biobakery.simg` in the `$TMPDIR` directory. In this way, containers will be available to you during your job, but they will be deleted when the job terminates (or fails).

### Bound directories
A Singularity container is much like having a separate machine that's running its own OS; as such, there is a wall between a container and your host OS by default. That is, unless you've [bound directories](http://singularity.lbl.gov/docs-mount) on the host OS to directories in the container during the container build. Binding means that the container "shares" a directory with your host OS, so that you can read and write to/from the host.

By default, the following directories are all (recursively) bound to a container for you:
- `$HOME`
- `/tmp`
- `/proc`
- `/sys`
- `/dev`

### Data directories
Try to keep all files you need while running `singularity run/exec/shell` (for example, data files, scripts, etc.) in a location rooted in the `$HOME` directory.** If your data is located in, for example, `/opt`, Singularity will not be aware of it.

Should you need files on Quest that are located outside of the bound-by-default directories (e.g. `/projects/b1042`), you can easily bind it upon calling `singularity`. For example, should you need access to the `/projects` directory to access data for an analysis you would like to run, simply bind it (and multiple other directories) with the flag `-B`:

```bash
$ singularity shell -B /projects mxnet_cpu.simg
```

Alternatively, you can use the `SINGULARITY_BINDPATH` environment variable to skip having to specify directories to bind every time you use `singularity`. More information on bind points can be found [here](http://singularity.lbl.gov/docs-mount).


