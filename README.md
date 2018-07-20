# Northwestern University Research Computing Services Singularity documentation and container files

[![https://www.singularity-hub.org/static/img/hosted-singularity--hub-%23e32929.svg](https://www.singularity-hub.org/static/img/hosted-singularity--hub-%23e32929.svg)](https://singularity-hub.org/collections/1271)

```
|-- docs (documentation)
|-- singularity_files
| |-- [container files]
|   |-- Singularity.[container tag]
|   |-- [files for pulling resources during container build]
|   |-- [files for running tests]
```

There can be multiple recipe files per container directory, for example, if there are both CPU and GPU versions of a single container.

Check the build status of each container in this repository on [Singularity Hub](https://singularity-hub.org/collections/1271)

Follow the [Singularity automated build documentation](https://github.com/singularityhub/singularityhub.github.io/wiki/Build-A-Container) for recipe file naming conventions for automating builds on Singularity Hub and for how to configure automated or manual builds on pushed commits.
