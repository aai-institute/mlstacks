# DEPRECATION WARNING: This code has been deprecated
# The maintained & current code can be found at src/mlstacks/terraform/
# under the same relative location.

# create s3 bucket for storing artifacts
resource "aws_s3_bucket" "zenml-artifact-store" {
  count         = var.enable_artifact_store ? 1 : 0
  bucket        = "${local.prefix}-${local.s3.name}"
  force_destroy = true

  tags = merge(
    local.tags,
    {
      name = "zenml-artifact-store"
    }
  )
}

# block public access to the bucket
resource "aws_s3_bucket_public_access_block" "example" {
  count  = var.enable_artifact_store ? 1 : 0
  bucket = aws_s3_bucket.zenml-artifact-store[0].id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = false
  restrict_public_buckets = false
}

resource "aws_s3_bucket_policy" "allow_access_from_another_account" {
  count  = var.enable_artifact_store ? 1 : 0
  bucket = aws_s3_bucket.zenml-artifact-store[0].id
  policy = data.aws_iam_policy_document.allow_access_from_another_account[0].json
}

data "aws_iam_policy_document" "allow_access_from_another_account" {
  count = var.enable_artifact_store ? 1 : 0
  statement {
    principals {
      type        = "AWS"
      identifiers = [aws_iam_role.ng[0].arn]
    }
    actions = [
      "s3:*",
    ]
    resources = [
      aws_s3_bucket.zenml-artifact-store[0].arn,
      "${aws_s3_bucket.zenml-artifact-store[0].arn}/*",
    ]
  }
}
