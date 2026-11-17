# __generated__ by Terraform
# Please review these resources and move them into your main configuration files.

# __generated__ by Terraform
resource "aws_instance" "zvit_plus" {
  ami                                  = "ami-0fd9576cca965bd19"
  associate_public_ip_address          = true
  availability_zone                    = "eu-north-1c"
  disable_api_stop                     = false
  disable_api_termination              = false
  ebs_optimized                        = true
  force_destroy                        = false
  get_password_data                    = false
  hibernation                          = false
  instance_initiated_shutdown_behavior = "stop"
  instance_type                        = var.instance_type
  key_name                             = "zvit-plus"
  monitoring                           = false
  placement_partition_number           = 0
  private_ip                           = "172.31.13.152"
  region                               = "eu-north-1"
  secondary_private_ips                = []
  security_groups                      = ["launch-wizard-2"]
  source_dest_check                    = true
  subnet_id                            = "subnet-05f2c3097a171a05a"
  tags = {
    Name = "zvit-plus"
  }
  tags_all = {
    Name = "zvit-plus"
  }
  tenancy                     = "default"
  user_data                   = null
  user_data_replace_on_change = null
  volume_tags                 = null
  vpc_security_group_ids      = ["sg-00f443336e650b74c"]
  capacity_reservation_specification {
    capacity_reservation_preference = "open"
  }
  cpu_options {
    core_count       = 1
    threads_per_core = 2
  }
  credit_specification {
    cpu_credits = "unlimited"
  }
  enclave_options {
    enabled = false
  }
  maintenance_options {
    auto_recovery = "default"
  }
  metadata_options {
    http_endpoint               = "enabled"
    http_protocol_ipv6          = "disabled"
    http_put_response_hop_limit = 2
    http_tokens                 = "required"
    instance_metadata_tags      = "disabled"
  }
  private_dns_name_options {
    enable_resource_name_dns_a_record    = true
    enable_resource_name_dns_aaaa_record = false
    hostname_type                        = "ip-name"
  }
  root_block_device {
    delete_on_termination = true
    encrypted             = true
    iops                  = 3000
    kms_key_id            = "arn:aws:kms:eu-north-1:290679927628:key/40166292-c636-41a4-accb-a12a351e6a17"
    tags                  = {}
    tags_all              = {}
    throughput            = 125
    volume_size           = 40
    volume_type           = "gp3"
  }
}
