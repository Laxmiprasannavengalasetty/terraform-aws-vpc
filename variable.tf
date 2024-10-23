variable "project_name"{

    type = string
}
variable "environment"{

     type = string
}
variable "vpc_cidr" {
  type        = string
  default     = "10.0.0.0/16"
  
}
variable "enable_dns_hostnames"{

    default = true
}
variable "common_tags"{

    default = {}
    
}
variable "vpc_tags"{

    default = {}
}
variable "igw_tags"{

    default = {}
}
variable "public_subnet_cidrs"{

    type = list(string)        # min 2 AZ and also restrict user if they provide less than or morethan 2 
    validation {

        condition = length(var.public_subnet_cidrs) ==2 
        error_message = "Please provide 2 valid public subnet CIDR"
    }
}

variable "public_subnet_tags"{

    default = {}
}

variable "private_subnet_cidrs"{

    type = list(string)        # min 2 AZ and also restrict user if they provide less than or morethan 2 
    validation {

        condition = length(var.private_subnet_cidrs) ==2 
        error_message = "Please provide 2 valid public subnet CIDR"
    }
}
variable "private_subnet_tags"{

    default = {}
}

variable "database_subnet_cidrs"{

    type = list(string)        # min 2 AZ and also restrict user if they provide less than or morethan 2 
    validation {

        condition = length(var.database_subnet_cidrs) ==2 
        error_message = "Please provide 2 valid public subnet CIDR"
    }
}
variable "database_subnet_tags"{

    default = {}
}
variable "database_subnet_group_tags"{

    default ={}
}
variable "nat_gateway_tags"{

    default = {}
}
variable "public_route_table_tags"{

    default = {}
}
variable "private_route_table_tags"{

    default = {}
}
variable "database_route_table_tags"{

    default = {}
}
variable "is_peering_required"{
    type = bool
    default = false
}
variable "vpc_peering_tags"{

    default = {}
}