#!/bin/bash

# Replace these variables with your own values
INSTANCE_NAME="group-1"
INSTANCE_NAME2="group-2"
INSTANCE_NAME3="group-3"
INSTANCE_NAME4="group-4"
ZONE="us-central1-a"
GROUP_NAME="instance-group-1"
GROUP_NAME2="instance-group-2"

# Function to check if VM instance is in the instance group
function is_instance_in_group {
  gcloud compute instance-groups unmanaged list-instances $GROUP_NAME --zone=$ZONE --format="value(instance)" | grep -q "^$INSTANCE_NAME$",$INSTANCE_NAME2$
}

function is_instance_in_group2 {
    gcloud compute instance-groups unmanaged list-instances $GROUP_NAME2 --zone=$ZONE --format="value(instance)" | grep -q "^$INSTANCE_NAME3$", $INSTANCE_NAME4$
}

# Check if the instance is already in the group
if is_instance_in_group; then
  read -p "The VM instance '$INSTANCE_NAME' '$INSTANCE_NAME2' is already in the instance group '$GROUP_NAME'. Do you want to remove it? (yes/no): " user_input
  if [ "$user_input" == "yes" ]; then
    gcloud compute instance-groups unmanaged remove-instances $GROUP_NAME --instances=$INSTANCE_NAME,$INSTANCE_NAME2 --zone=$ZONE
    echo "The VM instance '$INSTANCE_NAME' '$INSTANCE_NAME2' has been removed from the instance group '$GROUP_NAME'."
  else
    echo "The VM instance '$INSTANCE_NAME' '$INSTANCE_NAME2' was not removed from the instance group '$GROUP_NAME'."
  fi
else
  # Add the VM instance to the unmanaged instance group
  gcloud compute instance-groups unmanaged add-instances $GROUP_NAME --instances=$INSTANCE_NAME,$INSTANCE_NAME2 --zone=$ZONE
  echo "VM instance '$INSTANCE_NAME' '$INSTANCE_NAME2' has been added to the instance group '$GROUP_NAME' in zone '$ZONE'."
fi

if is_instance_in_group2; then
  read -p "The VM instance '$INSTANCE_NAME3' '$INSTANCE_NAME4' is already in the instance group '$GROUP_NAME2'. Do you want to remove it? (yes/no): " user_input
  if [ "$user_input" == "yes" ]; then
    gcloud compute instance-groups unmanaged remove-instances $GROUP_NAME2 --instances=$INSTANCE_NAME3,$INSTANCE_NAME4 --zone=$ZONE
    echo "The VM instance '$INSTANCE_NAME3' '$INSTANCE_NAME4' has been removed from the instance group '$GROUP_NAME2'."
  else
    echo "The VM instance '$INSTANCE_NAME3' '$INSTANCE_NAME4' was not removed from the instance group '$GROUP_NAME2'."
  fi
else
  # Add the VM instance to the unmanaged instance group
  gcloud compute instance-groups unmanaged add-instances $GROUP_NAME2 --instances=$INSTANCE_NAME3,$INSTANCE_NAME4 --zone=$ZONE
  echo "VM instance '$INSTANCE_NAME3' '$INSTANCE_NAME4' has been added to the instance group '$GROUP_NAME2' in zone '$ZONE'."
fi
