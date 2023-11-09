
### About Shoreline
The Shoreline platform provides real-time monitoring, alerting, and incident automation for cloud operations. Use Shoreline to detect, debug, and automate repairs across your entire fleet in seconds with just a few lines of code.

Shoreline Agents are efficient and non-intrusive processes running in the background of all your monitored hosts. Agents act as the secure link between Shoreline and your environment's Resources, providing real-time monitoring and metric collection across your fleet. Agents can execute actions on your behalf -- everything from simple Linux commands to full remediation playbooks -- running simultaneously across all the targeted Resources.

Since Agents are distributed throughout your fleet and monitor your Resources in real time, when an issue occurs Shoreline automatically alerts your team before your operators notice something is wrong. Plus, when you're ready for it, Shoreline can automatically resolve these issues using Alarms, Actions, Bots, and other Shoreline tools that you configure. These objects work in tandem to monitor your fleet and dispatch the appropriate response if something goes wrong -- you can even receive notifications via the fully-customizable Slack integration.

Shoreline Notebooks let you convert your static runbooks into interactive, annotated, sharable web-based documents. Through a combination of Markdown-based notes and Shoreline's expressive Op language, you have one-click access to real-time, per-second debug data and powerful, fleetwide repair commands.

### What are Shoreline Op Packs?
Shoreline Op Packs are open-source collections of Terraform configurations and supporting scripts that use the Shoreline Terraform Provider and the Shoreline Platform to create turnkey incident automations for common operational issues. Each Op Pack comes with smart defaults and works out of the box with minimal setup, while also providing you and your team with the flexibility to customize, automate, codify, and commit your own Op Pack configurations.

# Azure Web App Deployment Slot Issues

This incident type refers to problems with deployment slots in Azure webapps. These issues may include slot swaps failing or staging slots not behaving as expected. In order to resolve this type of incident, it is recommended to review the deployment slot configurations and ensure that app settings and connection strings are correctly propagated between slots. It is also important to investigate errors during swaps and any other slot-specific issues that may be causing the problem.

### Parameters

```shell
export RESOURCE_GROUP_NAME="PLACEHOLDER"
export WEBAPP_NAME="PLACEHOLDER"
export SLOT_NAME="PLACEHOLDER"
export TARGET_SLOT_NAME="PLACEHOLDER"
export APP_SETTINGS="PLACEHOLDER"
export CONNECTION_STRING_TYPE="PLACEHOLDER"
export CONNECTION_STRING="PLACEHOLDER"
```

## Debug

### List all deployment slots for a given webapp

```shell
az webapp deployment slot list --resource-group ${RESOURCE_GROUP_NAME} --name ${WEBAPP_NAME}
```

### Get the app settings for a given deployment slot

```shell
az webapp config appsettings list --resource-group ${RESOURCE_GROUP_NAME} --name ${WEBAPP_NAME} --slot ${SLOT_NAME}
```

### Get the connection strings for a given deployment slot

```shell
az webapp config connection-string list --resource-group ${RESOURCE_GROUP_NAME} --name ${WEBAPP_NAME} --slot ${SLOT_NAME}
```

### Swap two deployment slots

```shell
az webapp deployment slot swap --resource-group ${RESOURCE_GROUP_NAME} --name ${WEBAPP_NAME} --slot ${SLOT_NAME} --target-slot ${TARGET_SLOT_NAME}
```

### Get logs for a given deployment slot

```shell
az webapp log tail --resource-group ${RESOURCE_GROUP_NAME} --name ${WEBAPP_NAME} --slot ${SLOT_NAME}
```

## Repair

### Update and review deployment slot configurations this includes ensuring that each slot has the correct settings, such as the app settings and connection strings, and that they are correctly propagated between slots.

```shell
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
```