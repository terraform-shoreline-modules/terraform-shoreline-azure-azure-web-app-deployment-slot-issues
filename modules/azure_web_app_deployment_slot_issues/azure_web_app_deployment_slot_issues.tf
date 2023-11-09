resource "shoreline_notebook" "azure_web_app_deployment_slot_issues" {
  name       = "azure_web_app_deployment_slot_issues"
  data       = file("${path.module}/data/azure_web_app_deployment_slot_issues.json")
  depends_on = [shoreline_action.invoke_config_slots]
}

resource "shoreline_file" "config_slots" {
  name             = "config_slots"
  input_file       = "${path.module}/data/config_slots.sh"
  md5              = filemd5("${path.module}/data/config_slots.sh")
  description      = "Update and review deployment slot configurations this includes ensuring that each slot has the correct settings, such as the app settings and connection strings, and that they are correctly propagated between slots."
  destination_path = "/tmp/config_slots.sh"
  resource_query   = "host"
  enabled          = true
}

resource "shoreline_action" "invoke_config_slots" {
  name        = "invoke_config_slots"
  description = "Update and review deployment slot configurations this includes ensuring that each slot has the correct settings, such as the app settings and connection strings, and that they are correctly propagated between slots."
  command     = "`chmod +x /tmp/config_slots.sh && /tmp/config_slots.sh`"
  params      = ["CONNECTION_STRING","WEBAPP_NAME","RESOURCE_GROUP_NAME","APP_SETTINGS","CONNECTION_STRING_TYPE"]
  file_deps   = ["config_slots"]
  enabled     = true
  depends_on  = [shoreline_file.config_slots]
}

