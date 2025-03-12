#!/bin/bash

# Replace these variables with your own values
INSTANCE_NAME="group-1"
ZONE="us-central1-a"
GROUP_NAME="instance-group-1"

# Create a new VM instance (if not already created)
#gcloud compute instances create $INSTANCE_NAME --zone=$ZONE

# Add the VM instance to the unmanaged instance group
gcloud compute instance-groups unmanaged add-instances $GROUP_NAME --instances=$INSTANCE_NAME --zone=$ZONE

echo "VM instance '$INSTANCE_NAME' has been added to the instance group '$GROUP_NAME' in zone '$ZONE'."
