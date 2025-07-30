# Attach an AWS Managed Policy to the user
resource "aws_iam_user_policy_attachment" "s3_guest_policy_attachment" {
  user       = "accbu1"
  policy_arn = "arn:aws:iam::816351727812:policy/aws-guest-policy-terraform"
}