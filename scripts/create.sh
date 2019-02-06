#!/bin/bash

PROJECT_NAME='airflow'

# Create the base-container project that contains the images
oadm new-project $PROJECT_NAME --display-name=$PROJECT_NAME --description='Apache Airflow on OpenShift'

# dependencies
oc create -f deployments/airflow-secrets.yaml -n $PROJECT_NAME
oc create -f deployments/airflow-pv.yaml -n $PROJECT_NAME

# imagestream builds
oc create -f deployments/airflow-build.yaml -n $PROJECT_NAME

# # infrastructure
oc create -f deployments/airflow-database.yaml -n $PROJECT_NAME

# services
oc create -f deployments/airflow-deploy-webserver.yaml -n $PROJECT_NAME
oc create -f deployments/airflow-deploy-scheduler.yaml -n $PROJECT_NAME

# sidecar services
oc create -f deployments/git-sync.yaml -n $PROJECT_NAME

# other
oc create -f deployments/airflow-routes.yaml -n $PROJECT_NAME

# Install openshift-acme for TLS
#oc create -f https://raw.githubusercontent.com/tnozicka/openshift-acme/master/deploy/letsencrypt-live/single-namespace/{role,serviceaccount,imagestream,deployment}.yaml
#oc policy add-role-to-user openshift-acme --role-namespace="$(oc project --short)" -z openshift-acme
