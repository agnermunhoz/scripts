#!/bin/bash
gcloud config set compute/zone us-central1-a
gcloud container clusters create my-cluster --enable-autoscaling --min-nodes=1 --max-nodes=3
gcloud container clusters get-credentials my-cluster
kubectl create deployment hello-server --image=gcr.io/google-samples/hello-app:1.0
kubectl expose deployment hello-server --type=LoadBalancer --port 8080
read -p "Press any key to resume ..."
gcloud container clusters delete my-cluster --async
