alias minikube-docker-env="minikube docker-env | grep -oe 'DOCKER.*=\".*\"' | tr -d '\"'"
alias docker-rm-none="docker images | grep none | awk '{print $3}' | xargs -I {} docker ps -a --filter ancestor={} | awk '{print $1}' | grep -e '[a-z0-9]' | xargs -I {} docker rm {} | docker images | grep none | awk '{print $3}' | xargs -I {} docker rmi {}"
