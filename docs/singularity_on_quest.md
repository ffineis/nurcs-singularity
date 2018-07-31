Use: internal,external

# Using Singularity on Quest

On Quest, Singularity is installed system-wide, so you will always have access to the `singularity` command.

## Accessing containers

The `singularity` command is always used with a particular container: you will likely have already taken one of the following three steps:

1. You have built or downloaded a container on your local machine. You should upload it to Quest (recommended you use Cyberduck or sftp) if you have not already.

Here is an example of using `sftp` to upload the `my_container.simg` container to your home directory on Quest:
```bash
(my-local-machine) sftp [my username]@quest.it.northwestern.edu
<enter password>

put my_container.simg .
```

2. On Quest, you have identified, in the shared directory of Singularity containers, a container that you would like to use.

```bash
ls -la <PATH TO SHARED SINGULARITY CONTAINERS> 
```

3. [Pull](http://singularity.lbl.gov/docs-pull) a Singularity container maintained on [NU IT's Singularity Hub collection](https://www.singularity-hub.org/collections/1271), or pull a Docker image into a Singularity container.

For example, to pull the CPU-supported MXNet container into your home directory on Quest, run the following:

```bash
$ singularity pull shub://ffineis/nurcs-singularity:mxnet_cpu
```

When you pull a container from Singularity Hub or Docker, it will probably come with a long, gross file name. Rename it automatically during the pull with the `-name` flag:

```bash
$ singularity pull --name mxnet_cpu.simg shub://ffineis/nurcs-singularity:mxnet_cpu
```


## Using containers
Your main entrypoints into a Singularity container are `singularity exec`, `singularity shell`, and if your container has been designed to run like an application, `singularity run`.

Recall that `singularity exec` allows you run an arbitrary command from within your container as if it were available to you on your host OS - e.g. if the genomics tool `halla` isn't installed for you on Quest, running `singularity exec my_container.simg halla [args]` runs as though you had `halla` installed. Meanwhile, `singularity shell` is for entering an interactive session within the Singularity container. Therefore, the rule of thumb is this:

- Use `singularity exec` when you're submitting batch jobs to Quest.
- Use `singularity shell` when you're working in an interactive session on Quest.
- `singularity run` can be useful in a batch or interactive setting depending on the application launched from within the container when `run` is called.

### Interactive command line sessions and `singularity shell`
Suppose you do not have the MXNet library installed on Quest, but you have access to the container `mxnet_cpu.simg` with the library installed. Suppose you want to debug your MXNet code in an interactive command line session.

First, request an interactive session on a compute node(s). [Read more on interactive jobs on Quest](https://kb.northwestern.edu/69247#interactive).

```bash
$ msub -I -l nodes=1:ppn=4 -l walltime=01:00:00 -q short -A <allocationid>
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


### Batch jobs and `singularity exec`
If you want to submit a batch job on Moab via `msub` that leverages a Singularity container, you're either going to use `singularity exec` or `singularity run` (or both).

Suppose we have an .R script that uses command line flags (with the R package [`argparse`](https://github.com/trevorld/argparse/blob/master/exec/example.R)) that can train a machine learning model with MXNet and can also send new data through a model and save the predictions.





