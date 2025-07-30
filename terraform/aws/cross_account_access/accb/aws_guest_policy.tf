resource "aws_iam_policy" "aws_guest_policy_terraform" {
  name        = "aws-guest-policy-terraform"
  description = "Policy to allow read access to a specific S3 bucket"
  policy      = data.aws_iam_policy_document.aws_guest_policy_document.json
}
data "aws_iam_policy_document" "aws_guest_policy_document" {
  statement {
    effect = "Allow"
    actions = [
      "s3:GetObject",
      "s3:ListBucket",
      "s3:PutObject",
    ]

    resources = [
      "arn:aws:s3:::accau1-s3-demo-bucket-terraform",
      "arn:aws:s3:::accau1-s3-demo-bucket-terraform/*",
    ]
  }
}