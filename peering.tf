resource "aws_vpc_peering_connection" "peering"{

    count = var.is_peering_required ? 1 : 0
    vpc_id = aws_vpc.main.id # requestor
    peering_vpc-id = data.aws_vpc.default.id  #acceptor
    auto_accept = true
    tags = merge(

        var.common_tags,
        var.vpc_peering_tags,
        {
            Name = "${local.resource}-default"

        }
    )
}
resource "aws_route" "public_peering"{

    count = var.is_peering_required ? 1 :0
    route_table_id = aws.route_table.public.id
    destination_cidr_block = data.aws_vpc.default.cide_block
    aws_vpc_peering_connection_id = aws_vpc_peering_connection.peering[count.index].id
}
resource "aws_route" "private_peering"{

    count = var.is_peering_required ? 1 : 0
    route_table_id = aws.route_table.private.id
    destination_cidr_block = data.aws_vpc.default.cidr_block
    aws_vpc-aws_vpc_peering_connection_id =  aws_vpc_peering_connection.peering[count.index].id
    
}
resource "aws_route" "database_peering"{

    count = var.is_peering_required ? 1 :0
    route_table_id = aws.route_table.database.id
    destination_cidr_block = data.aws_vpc.default.cide_block
    aws_vpc_peering_connection_id = aws_vpc_peering_connection.peering[count.index].id
}