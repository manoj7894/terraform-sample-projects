# To create VPC endpoint
resource "aws_vpc_endpoint" "sqs_endpoint" {
  vpc_id = aws_vpc.vpc.id

  service_name      = "com.amazonaws.ap-south-1.sqs"
  vpc_endpoint_type = "Interface"

  // Attach the VPC endpoint to the subnet
  subnet_ids = [aws_subnet.public.id, aws_subnet.private.id]

  // Attach the VPC endpoint to a security group
  security_group_ids = [aws_security_group.example_security_group.id]

  // Enable private DNS name resolution
  private_dns_enabled = false

  // Attach a policy to the VPC endpoint
  policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": "*",
      "Action": "*",
      "Resource": "*"
    }
  ]
}
POLICY
}
