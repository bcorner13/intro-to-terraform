variable "chef_provision" { 
  type                      = "map"
  description               = "Configuration details for chef server"

  default = {
    server_url 	 	= "https://gsaohldrchef01.gsaws.local/organizations/gsdr"
    user_name           = "bcorner"
    user_key_path	= "~/chef-repo/.chef/client_pem/dr/bcorner.pem"
    recreate_client     = true
    }
}
