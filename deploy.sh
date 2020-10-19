#!/bin/sh

kubectl config use-context minikube

IMAGE=spring-docker-local

eval $(minikube docker-env)
./mvnw compile jib:dockerBuild -Dimage=$IMAGE

#Has to be deleted as with restart status check is not working
kubectl apply -f k8s/role.yaml
kubectl apply -f k8s/config.yaml
kubectl delete -f k8s/deploy.yaml
kubectl apply -f k8s/deploy.yaml

kubectl rollout status deploy/spring-docker-local --timeout 30s

#After this step wait for some seconds to access the endpoint via localhost
kubectl port-forward service/spring-docker-local 8080:8080