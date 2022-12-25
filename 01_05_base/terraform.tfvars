# MAC/LINUX
# aws ec2 create-key-pair --key-name tf_key --query 'KeyMaterial' --output text > tf_key.pem
###
# WINDOWS
# aws ec2 create-key-pair --key-name tf_key --query 'KeyMaterial' --output text | out-file -encoding ascii -filepath tf_key.pem

aws_access_key = "AKIAXFXVCGSTW5H6GAIU"

aws_secret_key = "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"

ssh_key_name = "tf_key"

#private_key_path = ""

variable "instance_type" {
  description = "Type of EC2 instance to provision"
  default     = "t3.nano"
}