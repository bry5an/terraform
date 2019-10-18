provider "aws" {
  region  = "us-east-1"
  profile = "main"
  alias   = "main"
}

provider "aws" {
  region  = "us-east-1"
  profile = "aux"
  alias   = "aux"
}

resource "aws_vpc_peering_connection" "peer" {
  peer_owner_id = data.aws_caller_identity.main.account_id
  peer_vpc_id   = data.terraform_remote_state.main.outputs.vpc_id
  vpc_id        = aws_vpc.eks-cluster-vpc.id
  auto_accept   = false
  peer_region   = "us-east-1"

  tags = {
    Name = "k8s-to-main"
    Side = "Requester"
  }
}

data "aws_caller_identity" "aux" {
  provider = aws.aux
}

# Get aux account resource IDs
data "terraform_remote_state" "aux" {
  backend = "s3"
  config = {
    bucket = "bucket-name-terraform"
    key    = "aux-vpc/terraform.tfstate"
    region = "us-east-1"
  }
}

output "peering_connection_id" {
  description = "ID of the peering connection to Build VPC to be used in Build connection"
  value       = aws_vpc_peering_connection.k8s-to-build.id
}

