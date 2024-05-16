# global-config-cmp
The global-config-cmp runs as a sidecar container in the repo-server pod.

## Releasing the changes with jenkins job

 Docker image build using `Github Actions` when `PR`  is created (pushed to `test` ecr repo) and when merged to master (pushed to `ga` ecr repo ).
