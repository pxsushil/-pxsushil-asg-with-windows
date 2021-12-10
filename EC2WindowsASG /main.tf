locals {
  userdata = <<-USERDATA
  <powershell>
  cd \Users\Administrator\Desktop\
  $contenttoupdate = ipconfig
  $content = Get-Content "C:\Users\Administrator\Desktop\config.txt"
  $content[5]=$contenttoupdate[8]
  $content | Set-Content C:\Users\Administrator\Desktop\config.txt 
 </powershell>
 <persist>true</persist>
  USERDATA
}

module "autoscale_group" {
  source      = "/home/professor/Desktop/Terraform/asg-with-windows/terraform-aws-ec2-autoscale-group"
  namespace   = "TTN_namespace"
  stage       = "Test_stage"
  environment = "Dev_environment"
  name        = "WindowsServers_name"
  # key_name    = "Windows"
  instance_market_options = {
    market_type = "spot"
  }

  # AMI withs sys ami-02d07010f32208709   # pass====>>>    WIYozpQyv-&C?hydqscC$j6iGx!!1EQa // C:\ProgramData\Amazon\EC2Launch\sysprep   
  #AMI With C:\ProgramData\Amazon\EC2-Windows\Launch\Scripts\InitializeDisks.ps1 -Schedule or InitializeInstance.ps1
  # withou sypre pass====>>>    L?Vh&8q$vM*PM3&8yuK8E)@CGO$iefXo   ami-03b566c5ffc1a0a8e  
  # Administrator   L?Vh&8q$vM*PM3&8yuK8E)@CGO$iefXo
  # pass====>>>     D-esS4ZhbD.qO.Tpr$xjJELf6yYCn(b2 
  image_id                    = "ami-02d07010f32208709"
  instance_type               = "c4.4xlarge"
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

  # Auto-scaling policies and CloudWatch metric alarms
  autoscaling_policies_enabled           = true
  cpu_utilization_high_threshold_percent = "70"
  cpu_utilization_low_threshold_percent  = "20"
}
