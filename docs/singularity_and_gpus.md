Use: internal, external

# Singularity and GPUs
One of the most obvious Singularity use cases is for GPU computing. The DevOps-related overhead in creating a GPU-ready computing environment is going to be beyond what a typical user will likely want to endure, and with Singularity we can deploy containers that come with the entire GPU ecosystem pre-configured and ready for use with Tensorflow, Keras, MXNet, etc.

The trickiest part about deploying a GPU-enabled Singularity container is that the CUDA library files and NVIDIA drivers must be installed or mounted within the container, and they must match the versions on Quest.

## GPU's with Singularity: using the `--nv` flag.
Singularity's main author, Greg Kurtzer, has made using Singularity with GPU's as simple as 

```bash
$ singularity run --nv container.simg [script]
```

where `--nv` is short for NVIDIA. This flag tells singularity to search for the NVIDIA drivers on the host, so that the host's driver files can be bound to the container.

#### Example: interactive compute session on a GPU partition
Below is an example of how to start up an interactive computing session on a GPU partition, download a GPU-enabled Tensorflow container, and inspect that Tensorflow has a GPU available to it. The version of Tensorflow on the container is subject to the NVIDIA drivers installed on the GPU partition, which has specific compatibility requirements with particular versions of CUDA, which in turn have specific compatibility with Tensorflow releases.

```bash
$ msub -I -l nodes=1:ppn=1:gpus=1 -l walltime=01:00:00 -q <queue name> -A <your allocation>

$ export SINGULARITY_PULLFOLDER=$TMP_DIR
$ singularity pull --name tf_gpu.simg shub://ffineis/nurcs-singularity:tensorflow_gpu
$ singularity shell --nv $TMP_DIR/tf_gpu.simg

$ python -c 'from tensorflow.python.client import device_lib; print(device_lib.list_local_devices())' # have tensorflow query the gpu's available to it
```


## CUDA requirements
Specific Tensorflow (and therefore Keras) releases are only compatible with specific CUDA releases. For example, [Tensorflow 1.7 ceased to support CUDA versions earlier than 8.0 and cuDNN versions earlier than 6.0](https://github.com/tensorflow/tensorflow/releases), CUDA 9.0 can't be used with Tensorflow 1.4, etc. It's [possible](http://www.python36.com/how-to-install-tensorflow-gpu-with-cuda-9-2-for-python-on-ubuntu/) to install Tensorflow 1.8 with CUDA 9.2 as well as CUDA 8.0 (the latter is what the USCD Supercomputer Center has deployed on their XSDED cluster - [GH recipe file](https://github.com/mkandes/naked-singularity/blob/master/definition-files/us/ucsd/sdsc/comet/tensorflow/tensorflow-gpu.def)).

Within the container, the easiest way to install CUDA (rather than mount) is to just Bootstrap an [NVIDIA CUDA Docker image](https://hub.docker.com/r/nvidia/cuda/) for the version matching a CUDA installation available on Quest via an Environment Module (e.g. 8.0 or 9.2). The CUDA and corresponding library/shared object files have to be added to the $PATH and $LD_LIBRARY_PATH.

Below is a table matching CUDA releases to their compatible NVIDIA driver version.

| CUDA version | NVIDIA driver version |
|--------------|-----------------------|
|CUDA 9.2:     |        396.xx         |
|CUDA 9.1:     | 387.xx                |
|CUDA 9.0:     | 384.xx                |
|CUDA 8.0      | 375.xx (GA2)          |
|CUDA 8.0:     | 367.4x                |
|CUDA 7.5:     | 352.xx                |
|CUDA 7.0:     | 346.xx                |
|CUDA 6.5:     | 340.xx                |
|CUDA 6.0:     | 331.xx                |
|CUDA 5.5:     | 319.xx                |
|CUDA 5.0:     | 304.xx                |
|CUDA 4.2:     | 295.41                |
|CUDA 4.1:     | 285.05.33             |
|CUDA 4.0:     | 270.41.19             |
|CUDA 3.2:     | 260.19.26             |
|CUDA 3.1:     | 256.40                |
|CUDA 3.0:     | 195.36.15             |


## NVIDIA requirements

#### Within the container
There are two options for building GPU-enabled containers:
1. (More difficult, less useful) Installing NVIDIA driver paths directly to the container, so that the container is configured to work explicitly with certain NVIDIA driver versions.

NVIDIA driver files can either be bound to the container upon calling `singularity` (recommended) or mounted on the Singularity container itself. As [this](http://gpucomputing.shef.ac.uk/education/creating_gpu_singularity/) **extremely useful** .bash script from the University of Sheffield discusses (and remedies), it's a bad idea to install the driver files directly within the container because drivers vary so much between GPU setups, so we'd wreck portability by installing one set of drivers. We'd write one container recipe file for each unique GPU configuration the Quest resource pool. The solution is to download the drivers depending on the NVIDIA drivers on the host, extract them into a directory and mount that directory into a fixed location within the container. The [document mentioned previously](http://gpucomputing.shef.ac.uk/education/creating_gpu_singularity/) outlines exactly how to do that. Unfortunately, we can't really do this on Quest because, among other things, it requires `sudo` access to create symlinks.

2. (Recommended) Bind the host's NVIDIA drivers to the container at run time.

Pursuing option 2., all the user needs to do is use the `--nv` (short for NVIDIA) flag to enable NVIDIA support, and singularity implicitly calls the `nvidia-smi` command line interface installed on the host (Quest) to gather the location of the NVIDIA driver files, binding that location to the container. In either case, it is likely that one container will need to be built for each unique NVIDIA driver version installed across the different GPU partitions on Quest.


## GPU workflow at SDSC
The San Diego Supercomputer Center's "Comet" HPC has two GPU partitions named "gpu" and "gpu-shared." Comet users can use a single Tensorflow container with either partition, even though the partitions presumably have different GPU node configurations (e.g. different mix of k80 or p100 nodes).

Note that the `nvidia-smi` CLI isn't available to Comet users until they request the "gpu" or "gpu-shared" partition through Slurm. For example, here's me requesting an interactive session with the gpu-shared partition and inspecting SDSC's GPU set-up:

<img src="img/comet_nvidia_smi_gpu_shared.png" width="500px" height="330px">

Further, note that the drivers on the "gpu-shared" partition are the same version on the "gpu" partition:

<img src="img/comet_nvidia_smi_gpu.png" width="500px" height="330px">

This is why SDSC can get away with using only the single Tensorflow singularity container located at /oasis/scratch/comet/mkandes/temp_project/singularity/images/. Users are supposed to use GPU-enabled containers in that directory via `singularity shell` (for an interactive session) or `singularity exec`. For example, below is a screenshot of how we could run an interactive Tensorflow session using way too many GPUs:

<img src="img/tf_on_comet.png" width="500px" height="330px">



