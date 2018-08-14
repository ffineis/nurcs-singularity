#!/bin/bash
#MSUB -A <allocation ID>
#MSUB -l walltime=05:00:00
#MSUB -j oe
#MSUB -q normal
#MSUB -N mxnet_modeler
#MSUB -l nodes=1:ppn=16

# Pull the container to a disposable directory.
export SINGULARITY_PULLFOLDER=$TMPDIR
singularity pull --name mxnet_cpu.simg shub://ffineis/nurcs-singularity:mxnet_cpu

# Suppose data is in /projects/b1042. Nickname this location, for binding to container.
export DATA_DIR=/projects/b1042/[my PI]

# Run the job: train a model, then run test data through it.
# Use `-B` to bind special directories to your container.
singularity exec -B $DATA_DIR $TMPDIR/mxnet_cpu.simg Rscript mxnet_model_builder.R \
 --train-data $DATA_DIR/training.csv \
 --model ./models/truck_model.RDS
singularity exec -B $DATA_DIR $TMPDIR/mxnet_cpu.simg Rscript mxnet_model_builder.R \
 --test-data $DATA_DIR/test.csv \
 --model ./truck_model.RDS