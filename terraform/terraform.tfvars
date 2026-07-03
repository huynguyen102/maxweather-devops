project     = "maxweather"
environment = "prod"
region      = "ap-southeast-1"
vpc_cidr    = "10.0.0.0/16"
az_count    = 2
# single_nat_gateway defaults to true (cost). Set false for one NAT per AZ (HA egress).
