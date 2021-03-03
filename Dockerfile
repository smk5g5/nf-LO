FROM continuumio/miniconda3 AS build

LABEL authors="andrea.talenti@ed.ac.uk" \
      description="Docker image containing base requirements for nf-LO pipelines"

# Install the package as normal:
COPY environment.yml .
RUN conda env create -f environment.yml

# Install conda-pack:
RUN conda install -c conda-forge conda-pack

# Use conda-pack to create a standalone enviornment
# in /venv:
RUN conda-pack -n nf-LO -o /tmp/env.tar && \
  mkdir /venv && cd /venv && tar xf /tmp/env.tar && \
  rm /tmp/env.tar

# We've put venv in same path it'll be in final image,
# so now fix up paths:
RUN /venv/bin/conda-unpack


# The runtime-stage image; we can use Debian as the
# base image since the Conda env also includes Python
# for us.
FROM debian:buster AS runtime

# Install procps in debian to make it compatible with reporting
RUN apt-get update && apt install -y procps g++ curl && apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*
RUN curl -o datasets 'https://ftp.ncbi.nlm.nih.gov/pub/datasets/command-line/LATEST/linux-amd64/datasets' && \
  mv datasets /usr/local/bin && \
  chmod a+x /usr/local/bin/datasets

# Copy /venv from the previous stage:
COPY --from=build /venv /venv

# When image is run, run the code with the environment
# activated:
ENV PATH /venv/bin/:$PATH
SHELL ["/bin/bash", "-c"]
