Use: internal

# Continuous Integration and Singularity-Hub

[Singularity-Hub](https://www.singularity-hub.org/) offers a solution for continuous integration and automated builds of anyone's Singularity containers. The process is simple, and requires very little configuration or adherence to new conventions.

On Singularity Hub, users host "collections" of containers. Each collection is connected to one Github repository, and one collection can contain many containers. Note that you cannot download the actual container *.img* or *.simg* files; those need to be hosted somewhere else, perhaps via a [Singularity Registry server](https://singularityhub.github.io/sregistry//). Instead, users will be able to pull them on an as-needed basis. What you get with Singularity-Hub integration is the following:

- A test that your recipe files indeed build correctly
- Hosts your singularity recipe files for others to download
- Includes metadata for your containers, e.g. OS specifications, build logs, and the option to add supplementary data to your collection like links to tutorials
- The ability to pull your containers from Singularity-Hub from the command line using `singularity pull shub://[username]/[collection name]:[tag]`


## Configuration
1. Create a Singularity Hub account and authenticate it on Github.
2. Create a new container collection and connect a Github repository to it. Singularity Hub will scan this repository for files titled "Singularity.[container tag]" anywhere in the repository and begin to attempt to build them, sequentially.
3. 