resource "aws_s3_bucket_policy" "allow_access_from_another_account" {
  bucket = aws_s3_bucket.s3_learn_aws.id
  policy = data.aws_iam_policy_document.allow_access_from_another_account.json
}

data "aws_iam_policy_document" "allow_access_from_another_account" {
  statement {
    principals {
      type        = "AWS"
      identifiers = ["arn:aws:iam::816351727812:root"]
    }
    sid = "PrincipalAccess"
    effect = "Allow"
    actions = [
        "s3:*",
    ]

    resources = [
      aws_s3_bucket.s3_learn_aws.arn,
      "${aws_s3_bucket.s3_learn_aws.arn}/*",
    ]
  }
}