resource "aws_vpc" "main" {
  cidr_block = var.vpc_cidr
  enable_dns_hostnames = var.enable_dns_hostnames

  tags = merge(
   var.common_tags,
   var.vpc_tags,
    {
          Name = local.resource_name

     }
    )
  }

  resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.main.id

  tags = merge (
    var.common_tags,
    var.igw_tags,
    {
       Name = local.resource_name
    }
  )
}
resource "aws_subnet" "public" {
  count = length(var.public_subnet_cidrs)
  vpc_id     = aws_vpc.main.id
  cidr_block = var.public_subnet_cidrs[count.index]
  availability_zone = local.az_names[count.index]
  map_public_ip_on_launch = true
  tags = merge (
    var.common_tags,
    var.public_subnet_tags,
    {
        Name = "${local.resource_name}-public-${local.az_names[count.index]}"          # projectname-dev-public-useast-1a
    }
  )
  }

  resource "aws_subnet" "private" {
  count = length(var.private_subnet_cidrs)
  vpc_id     = aws_vpc.main.id
  cidr_block = var.private_subnet_cidrs[count.index]
  availability_zone = local.az_names[count.index]

  tags = merge (
    var.common_tags,
    var.private_subnet_tags,
    {
        Name = "${local.resource_name}-private-${local.az_names[count.index]}"          # projectname-dev-private-useast-1a
    }
  )
  }
  
  resource "aws_subnet" "database" {
  count = length(var.database_subnet_cidrs)
  vpc_id     = aws_vpc.main.id
  cidr_block = var.database_subnet_cidrs[count.index]
  availability_zone = local.az_names[count.index]

  tags = merge (
    var.common_tags,
    var.database_subnet_tags,
    {
        Name = "${local.resource_name}-database-${local.az_names[count.index]}"          # projectname-dev-database-useast-1a
    }
  )
  }

  #aws_db_subnet_group for RDS
  resource "aws_db_subnet_group" "default" {
      name       = local.resource_name
      subnet_ids = aws_subnet.database[*].id

      tags = merge (
         var.common_tags,
         var.database_subnet_group_tags,
           {
              Name = local.resource_name
           }       
        )
  }

  resource "aws_eip" "nat"{           #elatic_ip for NAT 

     domain = "vpc"
  }
  # NAT resource name = main
  resource "aws_nat_gateway" "main" {               
  allocation_id = aws_eip.nat.id
  subnet_id     = aws_subnet.public[0].id

  tags = merge(
    var.common_tags,
    var.nat_gateway_tags,
    {
        Name = local.resource_name
    }
  )
  # To ensure proper ordering, it is recommended to add an explicit dependency
  # on the Internet Gateway for the VPC.
  depends_on = [aws_internet_gateway.gw]  # NAT depends on internet gateway by process here gw: internetgateway name
}
#public route table
resource aws_route_table "public"{
    vpc_id = var.vpc.main.id
    tags = merge(
      var.common_tags,
      var.public_route_table_tags,
      {
        Name = "${local.resource_name}-public"  #expense-public

      }
    )
}
# private route table
resource aws_route_table "private"{
    vpc_id = var.vpc.main.id
    tags = merge(
      var.common_tags,
      var.private_route_table_tags,
      {
        Name = "${local.resource_name}-private"  #expense-public

      }
    )
}
# database route table
resource aws_route_table "database"{
    vpc_id = var.vpc.main.id
    tags = merge(
      var.common_tags,
      var.database_route_table_tags,
      {
        Name = "${local.resource_name}-database"  #expense-public

      }
    )
}
# routes
resource "aws_routes" "public {
    route_table_id = aws_route_table.public.id
    destination_cidr_block = "0.0.0.0/0"
    nat_gateway_id = aws.nat_gateway.main.id      
}
resource "aws_route" "private_nat"{

    route_table_id = aws_route_table.private.id
    destination_cidr_block = "0.0.0.0/0"
    nat_gateway_id = aws.nat_gateway.main.id
}
resource "aws_route" "database_nat"{

    route_table_id = aws_route_table.database.id
    destination_cidr_block = "0.0.0.0/0"
    nat_gateway_id = aws.nat_gateway.main.id
}
# association
resource "aws_route_table_association" "public"{
    count =length(var.public_subnet_cidrs)
    subnet_id = aws.subnet.public[count.index].id
    route_table_id = aws.route_table.public.id
}
resource "aws_route_table_association" "private"{
    count = length(var.private_subnet_cidrs)
    subnet_id = aws.subnet.private[count.index].id
    route_table_id = aws.route_table.private.id
}
resource "aws_route_table_association" "database"{

    count = length(var.database_subnet_cidrs)
    subnet_id = aws.route_table.database.id
    route_table_id = aws.route_table.database.id
}