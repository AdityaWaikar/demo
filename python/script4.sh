#!/bin/bash

# Replace these variables with your own values
INSTANCE_NAME1="group-1"
INSTANCE_NAME2="group-2"
INSTANCE_NAME3="group-3"
INSTANCE_NAME4="group-4"
ZONE="us-central1-a"
GROUP_NAME1="instance-group-1"
GROUP_NAME2="instance-group-2"

# Function to check if VM instance is in the instance group
function is_instance_in_group {
  local group_name=$1
  local instance_name=$2
  gcloud compute instance-groups unmanaged list-instances $group_name --zone=$ZONE --format="value(instance)" | grep -q "^$instance_name$"
}

# Check and handle VM instances for Group 1
for instance in $INSTANCE_NAME1 $INSTANCE_NAME2; do
  if is_instance_in_group $GROUP_NAME1 $instance; then
    read -p "The VM instance '$instance' is already in the instance group '$GROUP_NAME1'. Do you want to remove it? (yes/no): " user_input
    if [ "$user_input" == "yes" ]; then
      gcloud compute instance-groups unmanaged remove-instances $GROUP_NAME1 --instances=$instance --zone=$ZONE
      echo "The VM instance '$instance' has been removed from the instance group '$GROUP_NAME1'."
    else
      echo "The VM instance '$instance' was not removed from the instance group '$GROUP_NAME1'."
    fi
  else
    gcloud compute instance-groups unmanaged add-instances $GROUP_NAME1 --instances=$instance --zone=$ZONE
    echo "VM instance '$instance' has been added to the instance group '$GROUP_NAME1' in zone '$ZONE'."
  fi
done

# Check and handle VM instances for Group 2
for instance in $INSTANCE_NAME3 $INSTANCE_NAME4; do
  if is_instance_in_group $GROUP_NAME2 $instance; then
    read -p "The VM instance '$instance' is already in the instance group '$GROUP_NAME2'. Do you want to remove it? (yes/no): " user_input
    if [ "$user_input" == "yes" ]; then
      gcloud compute instance-groups unmanaged remove-instances $GROUP_NAME2 --instances=$instance --zone=$ZONE
      echo "The VM instance '$instance' has been removed from the instance group '$GROUP_NAME2'."
    else
      echo "The VM instance '$instance' was not removed from the instance group '$GROUP_NAME2'."
    fi
  else
    gcloud compute instance-groups unmanaged add-instances $GROUP_NAME2 --instances=$instance --zone=$ZONE
    echo "VM instance '$instance' has been added to the instance group '$GROUP_NAME2' in zone '$ZONE'."
  fi
done
