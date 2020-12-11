#------------------------------------------------------------------------------#
# Key pair
#------------------------------------------------------------------------------#

# Performs 'ImportKeyPair' API operation (not 'CreateKeyPair')
resource "aws_key_pair" "main" {
  key_name_prefix = "${local.cluster_name}-"
  public_key      = file(var.public_key_file)
  lifecycle {
    ignore_changes = [public_key]
  }
  tags            = local.tags
}
