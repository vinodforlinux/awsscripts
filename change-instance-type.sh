#!/bin/bash

# Function to list AWS instances in the current region
list_instances() {

    aws ec2 describe-instances --query 'Reservations[*].Instances[*].{IP:PublicIpAddress,ID:InstanceId,Type:InstanceType,State:State.Name,Name:Tags[0].Value}' --output=table
    
}
# Function to list AWS instances types
list_instance_type() {
    aws ec2 describe-instance-types --query 'InstanceTypes[].{InstanceType: InstanceType, VCpus: VCpuInfo.DefaultVCpus, Memory: MemoryInfo.SizeInMiB}' --output json | jq -r '.[] | [.InstanceType, .VCpus, (.Memory/1024 | tostring + " GiB")]' | column -x -s "|" 
}

# Function to change the instance type based on user input
change_instance_type() {
    echo "Available Instances in the current region:"
    list_instances

    echo -n "Enter the AWS instance ID for which you want to change the instance type: "
    read instance_id

    echo -n "Enter the new instance type (e.g., t2.micro): "
    read new_instance_type

    echo "Changing instance type for $instance_id to $new_instance_type..."
    aws ec2 modify-instance-attribute --instance-id "$instance_id" --instance-type "{\"Value\": \"$new_instance_type\"}"
    echo "Instance type changed successfully."
}

# Main menu
while true; do
    echo "Options:"
    echo "1. List AWS Instances"
    echo "2. List Instance Type"
    echo "3. Change Instance Type"
    echo "4. Exit"
    read -p "Select an option (1/2/3/4): " choice

    case "$choice" in
        1)
            list_instances
            ;;
        2)
            list_instance_type
            ;;
        3)
            change_instance_type
            ;;
        4)
            echo "Exiting..."
            exit 0
            ;;
        *)
            echo "Invalid option. Please select 1, 2, 3 or 4."
            ;;
    esac
done
