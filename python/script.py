from google.cloud import compute_v1

def add_instance_to_unmanaged_instance_group(project, zone, instance_group_name, instance_url):
    instance_groups_client = compute_v1.InstanceGroupsClient()
    instance_groups_add_instances_request = compute_v1.InstanceGroupsAddInstancesRequest()
    instance_reference = compute_v1.InstanceReference(instance=instance_url)
    
    instance_groups_add_instances_request.instances = [instance_reference]
    
    operation = instance_groups_client.add_instances_unary(
        project=project,
        zone=zone,
        instance_group=instance_group_name,
        instance_groups_add_instances_request_resource=instance_groups_add_instances_request
    )
    
    print(f"Adding instance to unmanaged instance group '{instance_group_name}'...")
    wait_for_operation(operation)
    print("Instance added successfully.")

def wait_for_operation(operation):
    # Wait for the operation to complete
    pass

if __name__ == '__main__':
    # Replace these variables with your own values
    project = 'hardy-clover-447804-t3'
    zone = 'us-central1-a'
    instance_group_name = 'instance-group-1'
    instance_url = 'https://console.cloud.google.com/compute/instanceGroups/details/us-central1-a/instance-group-1?hl=en&project=hardy-clover-447804-t3'
    
    add_instance_to_unmanaged_instance_group(project, zone, instance_group_name, instance_url)
