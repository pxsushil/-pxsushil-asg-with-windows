locals {
  userdata = <<-USERDATA
 <powershell>
cd \Users\Administrator\Desktop\
ipconfig >update.txt
$contenttoupdate = Get-Content "C:\Users\Administrator\Desktop\update.txt" 
$content = Get-Content "C: \Users\Administrator\Desktop\config.txt"
$content[18]=$contenttoupdate[8]
$content | Set-Content C:\Users\Administrator\Desktop\config.txt 
 </powershell>
 <persist>true</persist>
  USERDATA
}

module "autoscale_group" {
  source      = "/home/professor/Desktop/Terraform/asg-with-windows/terraform-aws-ec2-autoscale-group"
  namespace   =  "TTN_namespace"
  stage       =  "Test_stage"
  environment =  "Dev_environment"
  name        =  "WindowsServers_name"
  key_name    =  "Windows"
  instance_market_options     =  {
    market_type = "spot" 
  #   # spot_options = {
  #   #   block_duration_minutes         = 60
  #   #   instance_interruption_behavior = "terminate"
  #   #   max_price                      = 0.045
  #   #   spot_instance_type             = "one-time"
  #   #   #Can be one-time, or persistent.
  #   #   valid_until                    = "2021-12-07T15:04:05Z"
  #   #   #valid_until - The end date of the request.
  #   # }
  }
  #pass====>>>mX5pvRj;P;igAgso*g@H)$WZCZ37MW=b
  image_id                    = "ami-034a231b550e0d072"
  instance_type               = "t3.large"
  security_group_ids          = ["sg-7ef51d38"]
  subnet_ids                  = ["subnet-eefef2a4", "subnet-d621a1e8", "subnet-44d9ef4b"]
  health_check_type           = "EC2"
  min_size                    = 1
  max_size                    = 2
  wait_for_capacity_timeout   = "5m"
  associate_public_ip_address = true
  user_data_base64            = base64encode(local.userdata)

  # All inputs to `block_device_mappings` have to be defined
  block_device_mappings = [
    {
      device_name  = "/dev/sda1"
      no_device    = "false"
      virtual_name = "root"
      ebs = {
        encrypted             = true
        volume_size           = 60
        delete_on_termination = true
        iops                  = null
        kms_key_id            = null
        snapshot_id           = null
        volume_type           = "standard"
      }
    }
  ]

  # tags = {
  #   Tier              = "1"
  #   KubernetesCluster = "us-west-2.testing.cloudposse.co"
  # }
  # Auto-scaling policies and CloudWatch metric alarms
  autoscaling_policies_enabled           = true
  cpu_utilization_high_threshold_percent = "70"
  cpu_utilization_low_threshold_percent  = "20"
}