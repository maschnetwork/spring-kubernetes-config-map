#!/bin/sh

kubectl config use-context minikube

IMAGE=spring-k8s-config-app

eval $(minikube docker-env)
./mvnw compile jib:dockerBuild -Dimage=$IMAGE

#Has to be deleted as with restart status check is not working
kubectl apply -f k8s/role.yaml
kubectl apply -f k8s/config.yaml
kubectl delete -f k8s/deploy.yaml --ignore-not-found
kubectl apply -f k8s/deploy.yaml

kubectl rollout status deploy/$IMAGE --timeout 30s

#After this step wait for some seconds to access the endpoint via localhost
kubectl port-forward service/$IMAGE 8080:8080