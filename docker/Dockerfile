FROM quay.io/jupyter/scipy-notebook:python-3.12
#https://jupyter-docker-stacks.readthedocs.io/en/latest/index.html

RUN pip install --no-cache-dir nbgitpuller
RUN pip install --no-cache-dir jupyter-resource-usage

USER root

RUN apt-get update && apt-get install -y --no-install-recommends \
      libnss-wrapper gettext-base acl && \
    rm -rf /var/lib/apt/lists/*

# entrypoint that maps current UID/GIDs to temp passwd/group files
COPY nss_wrapper.sh /usr/local/bin/nss_wrapper.sh
RUN chmod +x /usr/local/bin/nss_wrapper.sh

# keep existing start command but route through our wrapper
# (the stacks use tini + start-notebook.py under the hood)
ENTRYPOINT ["/usr/local/bin/nss_wrapper.sh"]
CMD ["start-notebook.py"]

# usual OpenShift-friendly perms
RUN fix-permissions "${CONDA_DIR}" && fix-permissions "/home/${NB_USER}"
USER ${NB_UID}
