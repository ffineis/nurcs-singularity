Use: internal,external

# Using Singularity on Quest

On Quest, Singularity is installed system-wide, so you will always have access to the `singularity` command.

The `singularity` command is always used with a particular container, so you'll need access to the the Singularity container (a container is just a file!) in order to use the `singularity run`, `exec`, or `shell` commands.

### Uploading a built image from your local machine
If you have built or downloaded a container on your local machine, you should upload it to Quest (with an ssh client such as [Cyberduck](https://cyberduck.io/) or `sftp`) if you have not already.

Here is an example of using `sftp` to upload the `my_container.simg` container to your home directory on Quest:
```bash
(my-local-machine) sftp [my username]@quest.it.northwestern.edu
<enter password>

put my_container.simg .
```

Due to the potentially large size of the container files themselves, it is recommended that instead, you `singularity pull` containers as needed on a per-job basis.

### Pulling an image from a Singularity Hub collection: `singularity pull`
[Pull](http://singularity.lbl.gov/docs-pull) a Singularity container maintained on [NU IT's Singularity Hub collection](https://www.singularity-hub.org/collections/1271), a container from any other Singularity Hub collection, or any Docker container available on Docker Hub. It is recommended that you pull containers on a per-job basis to the `$TMPDIR` directory created upon requesting resources from Moab. **Consult the best practices section below.**

For example, to pull the CPU-supported MXNet container into the disposable directory created when you launch a Moab job, run the following:

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

## Interactive jobs: `singularity shell` and `singularity exec`
Suppose you do not have the MXNet library installed on Quest, but you have access to the container `mxnet_cpu.simg` with the library installed. Suppose you want to debug your MXNet code in an interactive command line session.

First, request an interactive session on a compute node(s). [Read more on interactive jobs on Quest](https://kb.northwestern.edu/69247#interactive).

```bash
$ msub -I -l nodes=1:ppn=4 -l walltime=01:00:00 -q short -A <allocationid>
$ export SINGULARITY_PULLFOLDER=$TMPDIR
$ singularity pull --name mxnet_cpu.simg shub://ffineis/nurcs-singularity:mxnet_cpu
```

Let's assume that `mxnet_cpu.simg` is in your home directory. "Enter" the container with `singularity shell`, where you have MXNet installed as a Python and R library. **Once you enter the container with `shell`, it's like you're running on a new machine that has the MXNet libraries installed:**

```bash
$ singularity shell $TMPDIR/mxnet_cpu.simg
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

If your container is designed to run like an application, perhaps you do not need to "enter" the container via `singularity shell`, but execute it via `singularity exec`. The `exec` command allows you to execute a custom command within a container, but really from the host OS's command line. An example of `singularity exec` is available in the next section.


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
singularity exec $TMPDIR/mxnet_cpu.simg Rscript mxnet_model_builder.R --train-data ../data/training.csv --model ../models/truck_model.RDS
singularity exec $TMPDIR/mxnet_cpu.simg Rscript mxnet_model_builder.R --test-data test.csv --model ./truck_model.RDS


$ msub mxnet_modeler_submission.sh
```


## `singularity run`
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
Singularity containers can be deployed on GPUs, and can use them to run popular GPU-supported software. If the container is configured correctly, then all that should be necessary to leverage the GPU's from within your container is to run the container with the `--nv` (for "NVIDIA") flag.

Suppose you have requested an interactive job on a GPU partition on Quest and then pulled a GPU-enabled container. 
```bash
$ msub -I -l nodes=1:ppn=1:gpus=1 -l walltime=02:00:00 -q <queuename> -A <allocation ID>
$ export SINGULARITY_PULLFOLDER=$TMPDIR
$ singularity pull --name tensorflow_gpu.simg shub://ffineis/nurcs-singularity:tensorflow_gpu
```

When calling `shell`, `run`, or `exec`, just pass the `--nv` flag to enable NVIDIA support. Singularity will locate the host's NVIDIA drivers and share them with the container; the container should have a compatible release of CUDA installed and the correct `$PATH` variables set up.

```bash
$ singularity exec --nv python mnist_image_classifier.py
```


## Containers + MPI
Parallelization with containers is supported through the host's Message Passing Interface (MPI) installation. While MPI will need to be installed within your container in order for the MPI-enabled software within your container to take advantage of MPI in the first place, the Singularity itself does not spawn parallel threads from within a container. This, according to the Singularity developers, [would be a bit of a nightmare](http://singularity.lbl.gov/faq#can-i-containerize-my-mpi-application-with-singularity-and-run-it-properly-on-an-hpc-system). Instead, the host spawns multiple threads, each with a Singularity container process running on it.

If you run `mpirun` from **within** a container, you will **not** have parallelized your code. There is only one node available at a time to the conatiner's OS.

For this reason, a job involving an MPI-enabled container should be launched from the host's `mpirun` command:

```bash
$ mpirun -np 8 singularity exec <container.img> </path/to/contained_mpi_program>
```

For example, we have a container with OpenMPI and [mpi4py](https://mpi4py.readthedocs.io/en/stable/) installed available on Singularity Hub. We can pull it and run it on multiple Quest nodes. Note that the `mpirun` command will not be available to you immediately on starting a compute job; you will need to `load` the relevant environment module to gain access to `mpirun` before you launch your Singularity container's work in parallel.

```bash
$ msub -I -l nodes=4:ppn=1 -l walltime=02:00:00 -q short
$ export SINGULARITY_PULLFOLDER=$TMPDIR
$ singularity pull --name openmpi.simg shub://ffineis/nurcs-singularity:openmpi
$ module load python # (loads an MPI version compatible with mpi4py)
$ mpirun -np 4 singularity exec $TMPDIR/openmpi.simg python /opt/mpi_hello.py
```


# Best practices

## Pulling Singularity containers from Singularity Hub
If you would like to run a container on Quest, we recommend that you pull the container on a per-job basis to the `$TMPDIR` directory created whenever you request resources for a job on Moab. But `$TMPDIR` is a disposable directory. Do this, as opposed to keeping copies of the containers in your `$HOME` directory - container files can get very large, very quickly (order the order of Gb), so the `$TMPDIR` approach will save you hard drive space in your allocation.

In your job submission script, or from within an interactive Moab session:
1. Run `export SINGULARITY_PULLFOLDER=$TMPDIR`
2. Pull your container. For example, to pull the Biobakery container from NU IT Research Computing Services' Singularity Collection, add this:
```bash
singularity pull --name biobakery.simg shub://ffineis/nurcs-singularity:biobakery
```

Now you will have the container `biobakery.simg` in the `$TMPDIR` directory. In this way, containers will be available to you during your job, but they will be deleted when the job terminates (or fails).

## Bound directories
A Singularity container is much like having a separate machine that's running its own OS; as such, there is a wall between a container and your host OS by default. That is, unless you've [bound directories](http://singularity.lbl.gov/docs-mount) on the host OS to directories in the container during the container build. Binding means that the container "shares" a directory with your host OS, so that you can read and write to/from the host.

By default, the following directories are all (recursively) bound to a container for you:
- `$HOME`
- `/tmp`
- `/proc`
- `/sys`
- `/dev`

Try to keep all files you need while running `singularity run/exec/shell` (for example, data files, scripts, etc.) in a location rooted in the `$HOME` directory.** If your data is located in, for example, `/opt`, Singularity will not be aware of it. 

That said, as a Quest user, you may be part of an allocation that gives you access to a special Quest node. For example, perhaps you use of the [b1042 genomics cluster](https://www.it.northwestern.edu/research/user-services/quest/genomics.html), and all of your research group's data is located in a directory located at `/projects/b1042/my_PI/cluster_data`. Simply use the `-B` (for "bind") flag with the path to your `projects` allocation, and Singularity will let the container be aware of your data in that location. For example, should you need access to the `/projects` directory to access data for an analysis you would like to run, simply bind it (and multiple other directories) with the flag `-B`:

```bash
$ singularity shell -B /projects $TMPDIR/mxnet_cpu.simg
```

Alternatively, you can set the `SINGULARITY_BINDPATH` environment variable to skip having to specify directories to bind every time you use `singularity`. More information on bind points can be found [here](http://singularity.lbl.gov/docs-mount).


