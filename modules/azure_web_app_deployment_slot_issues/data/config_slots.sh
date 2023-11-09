#!/bin/bash

# Define variables
resource_group=${RESOURCE_GROUP_NAME}
webapp_name=${WEBAPP_NAME}
appsettings=${APP_SETTINGS}
conn_string_type=${CONNECTION_STRING_TYPE}
connection_strings=${CONNECTION_STRING}


# Get app settings, connection strings, and other configurations for each slot
slot_configurations=$(az webapp deployment slot list -g $resource_group -n $webapp_name --query "[].name" --output tsv)

for slot_name in $slot_configurations; do
    # Get app settings
    app_settings=$(az webapp config appsettings list -g $resource_group -n $webapp_name -s $slot_name --output json)
    
    # Get connection strings
    connection_strings=$(az webapp config connection-string list -g $resource_group -n $webapp_name -s $slot_name --output json)
    
    # Combine app settings, connection strings, and other configurations into a JSON object
    slot_configuration="{ \"name\": \"$slot_name\", \"appSettings\": $app_settings, \"connectionStrings\": $connection_strings }"
    
    # Check app settings and connection strings and update
    if [ "$app_settings" == "[]" ]; then
        echo "Error: $slot_name does not have app settings configured."
        az webapp config appsettings set --resource_group $resource_group --name $webapp_name --slot $slot_name --settings $app_settings
        echo "Updated: $slot_name app settings"
        az webapp config appsettings list -g $resource_group -n $webapp_name -s $slot_name --output json
    fi

    if [ "$connection_strings" == "[]" ]; then
        echo "Error: $slot_name does not have connection strings configured."
        az webapp config connection-string set --resource-group $resource_group --name $webapp_name --slot $slot_name --connection-string-type $conn_string_type --settings $connection_strings
        echo "Updated: $slot_name connection strings"
        az webapp config connection-string list -g $resource_group -n $webapp_name -s $slot_name --output json
    fi

    echo "Deployment slot $slot_name has been reviewed with the following configuration: $slot_configuration"
done