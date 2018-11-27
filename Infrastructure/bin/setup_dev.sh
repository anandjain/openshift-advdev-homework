 #!/bin/bash
# Setup Development Project
if [ "$#" -ne 1 ]; then
    echo "Usage:"
    echo "  $0 GUID"
    exit 1
fi

GUID=$1
echo "Setting up Parks Development Environment in project ${GUID}-parks-dev"

oc process -f Infrastructure/templates/configmap-template.yaml -n ${GUID}-parks-dev -p APPNAME="MLB Parks (Dev)" -p NAME=mlbparks-config | oc create -f -
oc process -f Infrastructure/templates/configmap-template.yaml -n ${GUID}-parks-dev -p APPNAME="National Parks (Dev)" -p NAME=nationalparks-config | oc create -f -
oc process -f Infrastructure/templates/configmap-template.yaml -n ${GUID}-parks-dev -p APPNAME="ParksMap (Dev)" -p NAME=parksmap-config | oc create -f -

#it is bad practice to put the password in the command line, generate it from the template instead
oc process -f Infrastructure/templates/mongodb/mongodb-persistent-template.yaml -n ${GUID}-parks-dev -p MONGODB_USER=mongodb -p MONGODB_PASSWORD=mongodb -p MONGODB_DATABASE=parks | oc create -f -

oc new-build --binary=true --name=mlbparks-buildconfig --image-stream=jboss-eap70-openshift:1.7 -n ${GUID}-parks-dev
oc new-build --binary=true --name=parksmap-buildconfig --image-stream=redhat-openjdk18-openshift:1.2 -n ${GUID}-parks-dev
oc new-build --binary=true --name=nationalparks-buildconfig --image-stream=redhat-openjdk18-openshift:1.2 -n ${GUID}-parks-dev

oc process -f Infrastructure/templates/deployment-config-template.yaml -p CONFIGMAP=mlbparks-config | oc create -f -
