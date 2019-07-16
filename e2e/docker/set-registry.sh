# DOCKER_QAT_REGISTRY value defined in Jenkins vars.
# Add insecure resgitry to push images.
DOCKER_QAT_REGISTRY=${DOCKER_QAT_REGISTRY:-"127.0.0.1:5000"}
sudo sh -c "echo '{\"insecure-registries\": [\"${DOCKER_QAT_REGISTRY}\"]}' > /etc/docker/daemon.json"
sudo sh -c "systemctl restart docker"
