# gds-lite: a fast stand-in for gds_env's base image (env/Dockerfile), for
# testing apps/gds_env without the hour-long conda build. See TESTING.md.
#
# It provides only what gds_env's frontend_code and frontend_agent Dockerfiles
# rely on, so those build on top of it unchanged:
#   - the same jupyter/minimal-notebook base (NB_USER, fix-permissions)
#   - a conda env named gds, first on PATH, with python (QUARTO_PYTHON) and
#     nodejs (frontend_agent's `npm install -g`)
#   - the gds kernel registered with `ipykernel install --user`, as
#     env/installers/install_conda_env.sh does; besides the kernel, this is
#     what creates ~/.local owned by jovyan, which gdsa's mounts rely on
#     (without it Docker creates ~/.local as root and opencode can't start)
#   - an Rscript that does nothing, so frontend_agent's R languageserver step
#     passes instead of compiling R packages for 10-15 minutes
#
# Build it on the VM as gds:latest, so apps/gds_env skips the base build:
#   docker build -t gds:latest tests/gds-lite

FROM quay.io/jupyter/minimal-notebook

LABEL org.opencontainers.image.description="gds-lite: test stand-in for the gds_env base image"

RUN mamba create -y -n gds python nodejs ipykernel \
 && mamba clean -afy \
 && fix-permissions /opt/conda/envs/gds

ENV PATH="/opt/conda/envs/gds/bin/:${PATH}"

RUN python -m ipykernel install --user --name gds --display-name "GDS-lite"

RUN printf '#!/bin/sh\n# gds-lite stand-in: no R here, accept and ignore everything\nexit 0\n' \
      > /opt/conda/envs/gds/bin/Rscript \
 && chmod 755 /opt/conda/envs/gds/bin/Rscript
