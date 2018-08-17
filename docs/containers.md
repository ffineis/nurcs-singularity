Use: internal,external

## Containers for Quest

We have available to the Northwestern computational research community a set of pre-built Singularity containers designed to work with the Quest High Performance Computing Cluster hosted by Northwestern IT.

Note that Singularity is currently installed on Quest system-wide, so there is no need to load the Singularity Environment Module. You should be able to run this:

```bash
$ singularity --version
```

to see the version of Singularity installed on Quest.

If you are curious as to the make up of any particular container, you can view their [Singularity recipe files](https://github.com/ffineis/nurcs-singularity/tree/master/singularity_files). Note our convention of appending either `_cpu` or `_gpu` to the container name to indicate whether a container has been configured for use with a GPU partition on Quest, in the case of software that has both CPU- and GPU-enabled flavors.

## Container descriptions
- **keras\_tf\_cpu.simg**: This container uses a Linux Ubuntu 16.04 (Xenial) OS and has installed on it the [Keras](https://keras.io/) deep learning package for python, version 2.2.0, configured to run on CPUs (this is not a GPU-enabled container). While Keras can work with several deep learning library backends, this container uses Tensorflow (version 1.8.0) for the backend neural network computations. Both Keras and Tensorflow are supported in this container for python 2.7 and python 3.5.

- **tensorflow\_cpu.simg**: This container uses a Linux Ubuntu 16.04 (Xenial) OS and has installed on it the Tensorflow, version 1.8.0, deep learning package for python 2.7. Within this container, Tensorflow was built from source with [Bazel](https://www.bazel.build/) (version 13.1).

- **tensorflow\_gpu.simg**: This container uses a Linux Ubuntu 14.04 (Trusty) OS and has installed on it the Tensorflow, version 0.8.0, deep learning package for python 2.7. The reason for this older Tensorflow version is due to the NVIDIA 352.39 drivers on the Quest GPU partition this container was developed for - which is only compatible with CUDA 7.5 - and Tensorflow support for CUDA 7.5 appears to have ended with the v1.0.0 release. This is important - not all `_gpu` containers will work with every partition - the version of the NVIDIA drivers dictates compatibility. Otherwise, the container is an augmented Docker image from NVIDIA with CUDA 7.5 installed on it.

- **mxnet\_cpu.simg**: This container uses a Linux Ubuntu 16.04 (Xenial) OS and has installed on it [MXNet](http://mxnet.incubator.apache.org/), a popular deep learning library from DMLC, the creators of the popular XGBoost library. MXNet bindings are installed for python 2.7 and R (version 3.4.4).

## Containers that NUIT should build
- LightGBM
- Keras, (updated) Tensorflow, MXNet GPU, PyTorch

