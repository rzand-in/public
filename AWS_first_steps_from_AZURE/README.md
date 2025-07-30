# Exploring AWS from an Azure background (sharing my beginner understanding of AWS)
## IAM, Accounts and Accounts' access 
I wrote this text to remind myself of my experience with AWS. I would be pleased if my notes can also help somebody else approaching AWS starting from an Azure outlook. I would also be glad if any error on the below can be brought to my attention and for any other meaningful suggestion.

The first things I considered when I started working with AWS was where to create the resources and how to access them. In Azure I was used to create my resources in a Resource Group and access them with a user created in the Azure Active Directory which is generated automatically when a new tenant is created. I was also concious that identity access and management (IAM) is paramount for cloud security. 

When one signs up for an AWS account he/she will have to specify an email address which will become the root user with all the powers over the account. Best practice suggests to protect that account with MFA, possibly remove its app keys and don't use it for ordinary operations. The root user can create IAM users and roles that can be used to build and/or access the infrastructure within the account. So AWS and Azure are similar in the way that the root user (AWS) or the Account Administrator (Azure) have all the powers on the respective tenants. They should not be used for ordinary operations, they should be protected with MFA and they can create users to which assign roles and permissions to other users which will run ordinary task. In Azure these ordinary users are created in a directory (AAD - Azure Active Directory) while in AWS they are created within the account. 

Initially my understanding was that an AWS account is the equivalent of an Azure Resource Group: a logical container where the resources are placed. But since every AWS account is isolated from each other, I thought they are more like an Azure Subscription, which before the Azure ARM api where the only logical container for Azure cloud resources. The article at https://learn.microsoft.com/en-us/azure/architecture/aws-professional/accounts#aws-accounts-vs-azure-subscriptions confirms the latter.

My thought at this point was that I would still use an AWS account as if it was an Azure Resource Group and create in there all the resources that share the same lifecycle. The problem with this approach would be how to allow cross-account communication. There are several ways to do that and a full explanation can be found in the AWS documentation:
* Cross account resource access in IAM - https://docs.aws.amazon.com/IAM/latest/UserGuide/access_policies-cross-account-resource-access.html
* AWS Organizations - https://docs.aws.amazon.com/organizations/latest/userguide/orgs_introduction.html . This can be extended with AWS Control Tower - https://docs.aws.amazon.com/accounts/latest/reference/when-to-use-control-tower.html
* AWS IAM Identity Center - https://docs.aws.amazon.com/singlesignon/latest/userguide/what-is.html

I found interesting the video at https://www.youtube.com/watch?v=QZKpufELZCA&pp=0gcJCfwAo7VqN5tD that talks about "AWS IAM vs IAM Identity Center"

## Adding Accounts
### Add an Account from the portal
I tried was to create 2 accounts from the AWS portal using the same email address.

I already created one account, so I logged on to the portal using the root account user and checked the account's settings.

The url to use to access an AWS account looks like https://[account_number].signin.aws.amazon.com/console. The account number can be difficult to remember, but one can create an alias for it (from the IAM service dashbord link) which would allow to use a more memorable url: https://[alias_name].signin.aws.amazon.com/console.

To add a new account using a previously used email address I had to add add a + symbol and something between the first part of the address and the '@' symbol e.g.:
if the email used for the first account was name.surname@domain.tld the email for the second account can be name.surname+1@domain.tld

Otherwise I would receive an email stating:

![AWS email](images/aws_email_already_associated_with_an_account.png?raw=true "AWS email")

Once a created the second account, I verified that it had nothing in common with the account previously created using the same email address apart the email recipient where they will send communications to. They cannot see each other and the 2 root accounts have a different credentials. One has to specify the + symbol and the additional characters between the first part of the email and the '@' symbol and a different password to access the second account generated with a common email.

### Add an Account from the command line
This is currently not possible as documented in the "AWS CLI & SDKs" tab in the article at https://docs.aws.amazon.com/accounts/latest/reference/manage-acct-creating.html 

## Cross account resource access in IAM (using the AWS cli)
To learn how to share a resource between accounts I looked at the article published at https://docs.aws.amazon.com/IAM/latest/UserGuide/access_policies-cross-account-resource-access.html and in order to get it working I had to slightly modify the policies shown in the article. Below you can also find the command line commands I used to verify the resource access. The documentation explains that we need to create policies to share resources and that there are identity-based policies and resource-based policies, see 
https://docs.aws.amazon.com/IAM/latest/UserGuide/access_policies_identity-vs-resource.html

An s3 bucket, which is similar to an Azure Storage Account, supports the Cross-account access using resource-based policies. 

From the AWS portal I created a new account named 'acca' and an IAM user named 'accau1'. I assigned to the accau1 user the AmazonS3FullAccess policy and created the security credentials to use the account via aws cli.

On my laptop I created a new AWS configure profile to use the newly created user accau1
```
aws configure --profile accau1 
AWS Access Key ID [None]: AKIAXKXXXXXXXXXXXXXX
AWS Secret Access Key [None]: 05+vNgxMEwHjXXXXXXXXXXXXXXXXXXXXXXXXXXXX
Default region name [None]: ca-central-1                            
Default output format [None]: json
```
I checked that there are no s3 buckets in this account
```
aws --profile accau1 s3api list-buckets
{
    "Buckets": [],
    "Owner": {
        "ID": "193ebf5335cf47ea87b27049455fa04604cf8308103b9a33e80f68e85c5777b6"
    },
    "Prefix": null
}
```
I created an s3 Bucket
```
aws --profile accau1 s3api create-bucket \
              --bucket accau1-s3-demo-bucket \
              --region ca-central-1 \
              --create-bucket-configuration LocationConstraint=ca-central-1

{
    "Location": "http://accau1-s3-demo-bucket.s3.amazonaws.com/"
}
```
I checked again for s3 buckets to verify that the bucket has now been created.
```
aws --profile accau1 s3api list-buckets
{
    "Buckets": [
        {
            "Name": "accau1-s3-demo-bucket",
            "CreationDate": "2025-07-16T19:11:13+00:00"
        }
    ],
    "Owner": {
        "ID": "193ebf5335cf47ea87b27049455fa04604cf8308103b9a33e80f68e85c5777b6"
    },
    "Prefix": null
}
```

From the AWS portal I created a second account named 'accb' and an IAM user named 'accbu1'. I assigned to the accbu1 user the AmazonS3ReadOnlyAccess policy and created the security credentials to use the account via cli.

I created an AWS configure profile for the user accbu1 and confirmed that I cannot see any bucket using this second account. (N.B.: This is not the right cmmand to see if the policy had effect but it shows that no s3 buckets are present in this account)

```
aws --profile accbu1 s3api list-buckets
{
    "Buckets": [],
    "Owner": {
        "ID": "16e1f4d01ea6fabba8db285b765bec1bf15efd19255b7d29c603f9c6ae26b1cb"
    },
    "Prefix": null
}
```
I than checked that there are no bucket policies attached to the newly created s3 bucket  using the accau1 user
```
aws --profile accau1 s3api get-bucket-policy --bucket accau1-s3-demo-bucket

An error occurred (NoSuchBucketPolicy) when calling the GetBucketPolicy operation: The bucket policy does not exist
```

I created the aws-x-account-policy.json file for a policy that I named aws-x-account-policy. (N.B.: this is slighltly different from the one on the AWS documentation)
```
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "PrincipalAccess",
            "Effect": "Allow",
            "Principal": {"AWS": "arn:aws:iam::816351727812:root"},
            "Action": "s3:*",
            "Resource": "arn:aws:s3:::accau1-s3-demo-bucket",
            "Resource": "arn:aws:s3:::accau1-s3-demo-bucket/*"
            }
        ]
}
```
And attached it as resource-based policy to the newly created bucket. This will allow all principals in in the accb full access to the bucket in the acca account if granted any s3 permissions.

```
aws --profile accau1 s3api put-bucket-policy --bucket accau1-s3-demo-bucket --policy file://aws-x-account-policy.json
```
N.B.: no output returned

I checked if the policy has been applied:
```
aws --profile accau1 s3api get-bucket-policy --bucket accau1-s3-demo-bucket
{
    "Policy": "{\"Version\":\"2012-10-17\",\"Statement\":[{\"Sid\":\"PrincipalAccess\",\"Effect\":\"Allow\",\"Principal\":{\"AWS\":\"arn:aws:iam::816351727812:root\"},\"Action\":\"s3:*\",\"Resource\":\"arn:aws:s3:::accau1-s3-demo-bucket\"}]}"
}
```

I then created the policy file aws-guest-policy.json. (N.B.: again, this is slighltly different from the one on the AWS documentation)

```
{
	"Version": "2012-10-17",
	"Statement": [
		{
			"Effect": "Allow",
			"Action": [
				"s3:Get*",
				"s3:List*",
				"s3:PutObject"
			],
			"Resource": [
				"arn:aws:s3:::accau1-s3-demo-bucket",
				"arn:aws:s3:::accau1-s3-demo-bucket/*"
			]
		}
	]
}
```

When I attempted to create the policy via cli I received an error

```
aws --profile accbu1 iam create-policy \
    --policy-name aws-guest-policy \
    --policy-document file://aws-guest-policy.json

An error occurred (AccessDenied) when calling the CreatePolicy operation: User: arn:aws:iam::816351727812:user/accbu1 is not authorized to perform: iam:CreatePolicy on resource: policy aws-guest-policy because no identity-based policy allows the iam:CreatePolicy action
```
To save time I created the policy from the portal, the command to assign a policy to a user would look like the below:
```
aws iam attach-user-policy --user-name john.doe --policy-arn arn:aws:iam::aws:policy/ReadOnlyAccess
```

From the portal I attached the policy to the accb account IAM user named accbu1. This user is now configured with 2 policies: the AmazonS3ReadOnlyAccess and the aws-guest-policy I just created.

I have then added from the portal 2 files to the s3 bucket and tested the access to the files from both accounts. The command to test the bucket access is the following. Below you can see that the bucket can be accessed by both the acca and accb accounts.
```
aws --profile accau1 s3 ls s3://accau1-s3-demo-bucket
2025-07-17 12:54:07     981811 Copilot_20250711_150601.png
2025-07-16 22:00:46    1063180 Copilot_20250711_152727.png

---

aws --profile accbu1 s3 ls s3://accau1-s3-demo-bucket
2025-07-17 12:54:07     981811 Copilot_20250711_150601.png
2025-07-16 22:00:46    1063180 Copilot_20250711_152727.png
```
But I would have had the same result if I had applied to the accb account IAM user named accbu1 only the AmazonS3ReadOnlyAccess policy. This because the account principal (the root account accb) has been given the s3 bucket full control with the policy attached to the bucket created in the acca account.

With either or both the AmazonS3ReadOnlyAccess and aws-guest-policy policies I can list the blob in the s3 bucket.

Plase note that the policies I created are slightly different from the one on the Amazon Documentation regarding the aws resources cross account access (https://docs.aws.amazon.com/IAM/latest/UserGuide/access_policies-cross-account-resource-access.html). Using the reource "arn:aws:s3:::accau1-s3-demo-bucket/* *" (with the /* * at the end like in the AWS documentation) I was unable to succeed with the command 
```
aws s3 ls
```
so I used the resource "arn:aws:s3:::accau1-s3-demo-bucket" (without the /* at the end).
Since I also wanted to try to write in the bucket from both accounts, I added the action "s3:PutObject" in the user policy in the account invited to access the s3 bucket (accb). To have this working I had to add the "arn:aws:s3:::accau1-s3-demo-bucket/* *" (with the /* * at the end) to both the s3 resource-based and the accb user identity-based policies. In summary, I was only able to list the blob in the bucket when the policies included the resource "arn:aws:s3:::accau1-s3-demo-bucket" and only able to upload to the bucket if the policies included the resource "Resource": "arn:aws:s3:::accau1-s3-demo-bucket/*" hence I added both to be able to read and write from the s3 storage.

Trying to ipload a file from accb, I was receiving the below error when only the "arn:aws:s3:::accau1-s3-demo-bucket" resource was present in the policies.
```
aws --profile accbu1 s3 cp /home/andrea/Downloads/Copilot_20250711_152108.png s3://accau1-s3-demo-bucket/
upload failed: ./Copilot_20250711_152108.png to s3://accau1-s3-demo-bucket/Copilot_20250711_152108.png An error occurred (AccessDenied) when calling the PutObject operation: Access Denied

```
Using the "arn:aws:s3:::accau1-s3-demo-bucket/*" resource in the policies solved the issue:
```
aws --profile accbu1 s3 cp /home/andrea/Downloads/Copilot_20250711_152108.png s3://accau1-s3-demo-bucket/
upload: ./Copilot_20250711_152108.png to s3://accau1-s3-demo-bucket/Copilot_20250711_152108.png

```
## Cross account resource access in IAM (using Ansible)
I configured the same setting with Ansible.

The accau1 and accbu1 users and their aws cli profiles have already been created.
I created a new s3 bucket with a playbook I named s3_bucket.yml:
```
---
- name: Create S3 bucket
  hosts: localhost
  gather_facts: false
  vars:
    bucket_name: accau1-s3-demo-bucket-ansible
  tasks:
    - name: Create S3 bucket
      amazon.aws.s3_bucket:
        name: '{{ bucket_name }}'
        region: ca-central-1
        state: present
        tags:
          Project: Ansible-S3
          Environment: Dev
      register: s3_bucket_result

    - name: Print bucket details
      ansible.builtin.debug:
        msg: "Bucket created successfully: {{ s3_bucket_result.name }}"
```
and executed it with the command:
```
AWS_PROFILE=accau1 ansible-playbook s3_bucket.yml
```
Its output was
```
[WARNING]: No inventory was parsed, only implicit localhost is available
[WARNING]: provided hosts list is empty, only localhost is available. Note that the implicit localhost does not match 'all'

PLAY [Create S3 bucket] ********************************************************************************************************************************

TASK [Create S3 bucket] ********************************************************************************************************************************
ok: [localhost]

TASK [Print bucket details] ****************************************************************************************************************************
ok: [localhost] => {
    "msg": "Bucket created successfully: accau1-s3-demo-bucket-ansible"
}

PLAY RECAP *********************************************************************************************************************************************
localhost                  : ok=2    changed=0    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0   
```
N.B. My laptop AWS cli profile configuration doesn't have a default profile. I had to specify one and in any case since we are working with 2 profiles wee need a way to tell Ansible which profile to use. There are different ways to specify wich account to use to run the Ansible playbook.
One can export the profile variable:
```
export AWS_PROFILE=my-profile-name
ansible-playbook my-playbook.yml
```
Assign it inline with the Ansible command as I chose to do:
```
AWS_PROFILE=my-profile-name ansible-playbook my-playbook.yml
```
or specify the profile in the playbook itself:
```
- name: Describe EC2 instances
  amazon.aws.ec2_instance_info:
    region: us-east-1
  vars:
    aws_profile: my-profile-name
```
The new bucket has now been created:
```
aws --profile accau1 s3api list-buckets
{
    "Buckets": [
        {
            "Name": "accau1-s3-demo-bucket",
            "CreationDate": "2025-07-17T19:32:25+00:00"
        },
        {
            "Name": "accau1-s3-demo-bucket-ansible",
            "CreationDate": "2025-07-21T19:08:32+00:00"
        }
    ],
    "Owner": {
        "ID": "193ebf5335cf47ea87b27049455fa04604cf8308103b9a33e80f68e85c5777b6"
    },
    "Prefix": null
}
```
But no policies are attached to it:
```
aws --profile accau1 s3api get-bucket-policy --bucket accau1-s3-demo-bucket-ansible

An error occurred (NoSuchBucketPolicy) when calling the GetBucketPolicy operation: The bucket policy does not exist
```
To attach the policy I added the policy attribute in the s3_bucket.yml file like shown below.
```
cat s3_bucket.yml 
---
- name: Create S3 bucket
  hosts: localhost
  gather_facts: false
  vars:
    bucket_name: accau1-s3-demo-bucket-ansible
  tasks:
    - name: Create S3 bucket
      amazon.aws.s3_bucket:
        name: '{{ bucket_name }}'
        policy: "{{ lookup( 'file','aws-x-account-policy.json' ) }}"
        region: ca-central-1
        state: present
        tags:
          Project: Ansible-S3
          Environment: Dev
      register: s3_bucket_result

    - name: Print bucket details
      ansible.builtin.debug:
        msg: "Bucket created successfully: {{ s3_bucket_result.name }}"
```
The aws-x-account-policy.json file used in the policy contains the following lines:
```
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "PrincipalAccess",
            "Effect": "Allow",
            "Principal": {"AWS": "arn:aws:iam::816351727812:root"},
            "Action": "s3:*",
            "Resource": "arn:aws:s3:::accau1-s3-demo-bucket/*"
            }
        ]
}
```
Running the playbook again with 
```
AWS_PROFILE=accau1 ansible-playbook s3_bucket.yml
```
I receive
```
PLAY RECAP *********************************************************************************************************************************************
localhost                  : ok=2    changed=0    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0   
```
And I can verifiy that the policy is now been configured
```
aws --profile accau1 s3api get-bucket-policy --bucket accau1-s3-demo-bucket-ansible
{
    "Policy": "{\"Version\":\"2012-10-17\",\"Statement\":[{\"Sid\":\"PrincipalAccess\",\"Effect\":\"Allow\",\"Principal\":{\"AWS\":\"arn:aws:iam::816351727812:root\"},\"Action\":\"s3:*\",\"Resource\":\"arn:aws:s3:::accau1-s3-demo-bucket-ansible/*\"}]}"
}
```
At this point the configuration  of the s3 bucket is complete, time to configure the user policy.
I created the fle aws-guest-policy-ansible.json.j2

```
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect" : "Allow", 
            "Action" : [ 
                "s3:Get*", 
                "s3:List*",
                "s3:PutObject"
            ], 
            "Resource": [
                "arn:aws:s3:::accau1-s3-demo-bucket-ansible",
                "arn:aws:s3:::accau1-s3-demo-bucket-ansible/*"
            ],
        } 
    ]
}
```
This is the template to create the policy for the invited account user (accbu1) to access the s3 bucket in the other account (acca)
To generate the policy I created the playbook aws-create-policy-ansible.yml:
```
- name: Create S3 bucket
  hosts: localhost
  gather_facts: false

  tasks:
# Create a policy
    - name: Create IAM Managed Policy
      amazon.aws.iam_managed_policy:
        policy_name: "aws-guest-policy-ansible"
        policy_description: "A Helpful managed policy"
        policy: "{{ lookup('template', 'aws-guest-policy-ansible.json.j2') }}"
        state: present
```
And run it with:
```
AWS_PROFILE=accbu1 ansible-playbook aws-create-policy-ansible.yml
```
I received several errors because the user accbu1 needed some permissions to be able to create (e later attach) the policy.
I assigned to the accbu1 user the necessary permission from the AWS portal by creating and attaching the policy AWS-manage-policies-ansible which reads:
```
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": [
                "iam:ListPolicies",
                "iam:CreatePolicy",
                "iam:GetPolicy",
                "iam:ListPolicyVersions",
                "iam:GetPolicyVersion",
                "iam:ListAttachedUserPolicies",
                "iam:AttachUserPolicy",
                "iam:GetUser"
            ],
            "Resource": [
                "*"
            ]
        }
    ]
}
```
With the right permission I finally saw the playbook succeed:
```
AWS_PROFILE=accbu1 ansible-playbook aws-create-policy-ansible.yml 
[WARNING]: No inventory was parsed, only implicit localhost is available
[WARNING]: provided hosts list is empty, only localhost is available. Note that the implicit localhost does not match 'all'

PLAY [Create S3 bucket] ********************************************************************************************************************************

TASK [Create IAM Managed Policy] ***********************************************************************************************************************
ok: [localhost]

PLAY RECAP *********************************************************************************************************************************************
localhost                  : ok=1    changed=0    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0   
```
I can now attach the policy to the user with the attach-user-policy-ansible.yml playbook:
```
---
- name: Create S3 bucket
  hosts: localhost
  gather_facts: false

  tasks:
    - name: Attach policy to the accbu1 IAM user
      amazon.aws.iam_user:
        name: accbu1 # Replace with the actual username
        managed_policies:
          - arn:aws:iam::816351727812:policy/aws-guest-policy-ansible
        state: present
```
which I run with:
```
AWS_PROFILE=accbu1 ansible-playbook attach-user-policy-ansible.yml 
[WARNING]: No inventory was parsed, only implicit localhost is available
[WARNING]: provided hosts list is empty, only localhost is available. Note that the implicit localhost does not match 'all'

PLAY [Create S3 bucket] ********************************************************************************************************************************

TASK [Attach policy to the accbu1 IAM user] ************************************************************************************************************
[DEPRECATION WARNING]: The 'iam_user' return key is deprecated and will be replaced by 'user'. Both values are returned for now. This feature will be 
removed from amazon.aws in a release after 2024-05-01. Deprecation warnings can be disabled by setting deprecation_warnings=False in ansible.cfg.
ok: [localhost]

PLAY RECAP *********************************************************************************************************************************************
localhost                  : ok=1    changed=0    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0   
```
The configuration is now complete and I am able to upload files to the new s3 bucket:
```
aws --profile accbu1 s3 cp /home/andrea/Downloads/Copilot_20250711_152108.png s3://accau1-s3-demo-bucket-ansible/
upload: ../Downloads/Copilot_20250711_152108.png to s3://accau1-s3-demo-bucket-ansible/Copilot_20250711_152108.png
```

## Cross account resource access in IAM (using Terraform)
I configured the same setting again, on a different s3 bucket using Terraform.

The accau1 and accbu1 users and their aws cli profiles have already been created and even though this is not my preferred choice I will use them to run Terraform. What I don't like is the fact that the credentials are written on my system, although in a hidden file in my user profile. Will explore later how to avoid this.

I started by creating 2 files: provider.tf for the aws configuration:
```
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }
  }
}

# Configure the AWS Provider
provider "aws" {
  region  = "ca-central-1"
  profile = "accau1"
}
``` 
and s3.tf that creates the bucket:
```
resource "aws_s3_bucket" "s3_learn_aws" {
  bucket = "accau1-s3-demo-bucket-terraform"

  tags = {
    method      = "terraform"
    environment = "dev"
  }
}
```
These are minimal configurations and have hardcoded values like the name of the profile I want to use to create the resource: accau1.

I have then moved into the directory where I stored my files and initialized terraform:
```
terraform init
```
and received a successful output:
```
Initializing the backend...
Initializing provider plugins...
- Finding latest version of hashicorp/aws...
- Installing hashicorp/aws v6.6.0...
- Installed hashicorp/aws v6.6.0 (signed by HashiCorp)
Terraform has created a lock file .terraform.lock.hcl to record the provider
selections it made above. Include this file in your version control repository
so that Terraform can guarantee to make the same selections by default when
you run "terraform init" in the future.

Terraform has been successfully initialized!

You may now begin working with Terraform. Try running "terraform plan" to see
any changes that are required for your infrastructure. All Terraform commands
should now work.

If you ever set or change modules or backend configuration for Terraform,
rerun this command to reinitialize your working directory. If you forget, other
commands will detect it and remind you to do so if necessary.
```
I validated the terraform code with:
```
terraform validate
```
and obtained the output:
```
Success! The configuration is valid.
```
Run the terraform plan:
```
terraform plan
```
and received the output:
```
Terraform used the selected providers to generate the following execution plan. Resource actions are indicated with
the following symbols:
  + create

Terraform will perform the following actions:

  # aws_s3_bucket.s3_learn_aws will be created
  + resource "aws_s3_bucket" "s3_learn_aws" {
      + acceleration_status         = (known after apply)
      + acl                         = (known after apply)
      + arn                         = (known after apply)
      + bucket                      = "accau1-s3-demo-bucket-terraform"
      + bucket_domain_name          = (known after apply)
      + bucket_prefix               = (known after apply)
      + bucket_region               = (known after apply)
      + bucket_regional_domain_name = (known after apply)
      + force_destroy               = false
      + hosted_zone_id              = (known after apply)
      + id                          = (known after apply)
      + object_lock_enabled         = (known after apply)
      + policy                      = (known after apply)
      + region                      = "ca-central-1"
      + request_payer               = (known after apply)
      + tags                        = {
          + "environment" = "dev"
          + "method"      = "terraform"
        }
      + tags_all                    = {
          + "environment" = "dev"
          + "method"      = "terraform"
        }
      + website_domain              = (known after apply)
      + website_endpoint            = (known after apply)

      + cors_rule (known after apply)

      + grant (known after apply)

      + lifecycle_rule (known after apply)

      + logging (known after apply)

      + object_lock_configuration (known after apply)

      + replication_configuration (known after apply)

      + server_side_encryption_configuration (known after apply)

      + versioning (known after apply)

      + website (known after apply)
    }

Plan: 1 to add, 0 to change, 0 to destroy.

────────────────────────────────────────────────────────────────────────────────────────────────────────────────────

Note: You didn't use the -out option to save this plan, so Terraform can't guarantee to take exactly these actions
if you run "terraform apply" now.
```
Ultimately run the terraform apply:
```
terraform apply
```
which returned the output:
```
Terraform used the selected providers to generate the following execution plan. Resource actions are indicated with
the following symbols:
  + create

Terraform will perform the following actions:

  # aws_s3_bucket.s3_learn_aws will be created
  + resource "aws_s3_bucket" "s3_learn_aws" {
      + acceleration_status         = (known after apply)
      + acl                         = (known after apply)
      + arn                         = (known after apply)
      + bucket                      = "accau1-s3-demo-bucket-terraform"
      + bucket_domain_name          = (known after apply)
      + bucket_prefix               = (known after apply)
      + bucket_region               = (known after apply)
      + bucket_regional_domain_name = (known after apply)
      + force_destroy               = false
      + hosted_zone_id              = (known after apply)
      + id                          = (known after apply)
      + object_lock_enabled         = (known after apply)
      + policy                      = (known after apply)
      + region                      = "ca-central-1"
      + request_payer               = (known after apply)
      + tags                        = {
          + "environment" = "dev"
          + "method"      = "terraform"
        }
      + tags_all                    = {
          + "environment" = "dev"
          + "method"      = "terraform"
        }
      + website_domain              = (known after apply)
      + website_endpoint            = (known after apply)

      + cors_rule (known after apply)

      + grant (known after apply)

      + lifecycle_rule (known after apply)

      + logging (known after apply)

      + object_lock_configuration (known after apply)

      + replication_configuration (known after apply)

      + server_side_encryption_configuration (known after apply)

      + versioning (known after apply)

      + website (known after apply)
    }

Plan: 1 to add, 0 to change, 0 to destroy.

Do you want to perform these actions?
  Terraform will perform the actions described above.
  Only 'yes' will be accepted to approve.

  Enter a value: yes

aws_s3_bucket.s3_learn_aws: Creating...
aws_s3_bucket.s3_learn_aws: Creation complete after 2s [id=accau1-s3-demo-bucket-terraform]

Apply complete! Resources: 1 added, 0 changed, 0 destroyed.
```
 I then added the s3_policy_x_account_access.tf file to configure the policy that allow the accb identities to access the bucket: 
 ```
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
      "${aws_s3_bucket.s3_learn_aws.arn}/*",
    ]
  }
}
```
After running the terraform apply I verified from the AWS portal that the policy attached to the new bucket was the same as the ones attached when I created the resources via cli or ansible.

Time now to create the guest policy in the accb account. In a different directory I created the files provider.tf:
```
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }
  }
}

# Configure the AWS Provider
provider "aws" {
  region  = "ca-central-1"
  profile = "accbu1"
}
```
and aws_guest_policy.tf:
```
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
```
After running the terraform apply command the new policy aws-guest-policy-terraform shows up in the accb tenant.

To attach the policy to the accbu1 user I wrote the file attach_guest_policy.tf:
```
# Attach an AWS Managed Policy to the user
resource "aws_iam_user_policy_attachment" "s3_guest_policy_attachment" {
  user       = "accbu1"
  policy_arn = "arn:aws:iam::816351727812:policy/aws-guest-policy-terraform"
}
```
Running the terraform apply one more time the policy applied to the user accbu1. N.B.: the user accbu1 has been granted the necessary permission to run the above configurations during the ansible configureation reported above.

We can now try to add a file to the acca s3 bucket using the accbu1 (different account) user:
```
aws --profile accbu1 s3 cp /home/andrea/Downloads/Copilot_20250711_152108.png s3://accau1-s3-demo-bucket-terraform/
```
and the output
```

upload: ../../../../../../Downloads/Copilot_20250711_152108.png to s3://accau1-s3-demo-bucket-terraform/Copilot_20250711_152108.png
```
confirmed that the file has been uploaded.

And I can also list the blobs in the bucket:
```
aws --profile accbu1 s3 ls s3://accau1-s3-demo-bucket-terraform
2025-07-29 16:02:57     984885 Copilot_20250711_152108.png
```

## Adding and removing Organizations with the following lines:
### Add an Organization from the portal
To manage more accounts - which we can think as resources' containers - from the same user one can use organizations.

To build an organization I logged on as my root account to the AWS portal and searched for organization in the AWS console.

![AWS email](images/aws_console_search_organization.png?raw=true "Search for organization")

Clicked "AWS Organizations" under services and clicked the "Create an organization button"

![Create an organization button](images/aws_create_organization.png?raw=true "Create an organization button")

This web page also provide very useful help and information. I personally like the succint way the AWS help is provided.

Upon creating an organization we are reminded that the account from which we are operating will become the managrmrnt account for the organization.

![Organization management account](images/aws_organization_management_account.png?raw=true "Organization management account")

The important thing here is that governance policies don't apply to the management account and so it is best practice **not** to build resources in this account. 

See https://docs.aws.amazon.com/organizations/latest/userguide/orgs_best-practices_mgmt-acct.html for more best practices.

![Organization created](images/aws_organization_created.png?raw=true "Organization created")

Creating the organization is quick. As soon as the organization is created we can add accounts simply clicking a button.

![Manage organization accounts](images/aws_add_an_account_to_an_organization.png?raw=true "Manage organization accounts")

I invited the account I created using the same email address of the management account. To do so I had to use the account id in the invitation since the email address with the added + symbol and characters before the @ symbol did not work.

I received an email with the invitation and a link but - because of the common email address - the link did not wok and to accept the invitation I had to log on to the invited account console using its the root user, moved to the "AWS Organization" section and clicked on the "View 1 invitation" button.

![Oganization invitation received](images/aws_organization_invitation_received.png?raw=true "Oganization invitation received")

and then accept the invitation.

![Oganization invitation accepted](images/aws_organization_invitation_accepted.png?raw=true "Oganization invitation accepted")

I also created an account from within the organization. Since I wanted to use the same email address used to create the previous accounts, I had to add a + symbol and few characters before the @ symbol for the email of the root account. To set the password for the account I clicked the link for the forgotten password on the console login screen.

I now can see 3 account listed in the organization if I log on to the aws console with management account root user (or IAM Admin user) and navigate to the "AWS Organizations" service.

Logging on to the console with the root credentials for the other accounts that are member of the organization and navigating to the "AWS Organizations" service I am able to see the organization id of which the account is a member.

Each of these accounts have their own root user, it is recommended to centralize the root user and remove the root credentials of all the accounts other than the management one.

At https://docs.aws.amazon.com/IAM/latest/UserGuide/id_root-enable-root-access.html AWS provides good documentation about how to centralize the root account.

Before looking at that I want to try and remove the organization and recreate it via command line.

### Remove an Organization from the portal

To remove the organization I logged on the management account with the root usernd navigate to the "AWS Organizations" service "Settings new" link.

![Oganization delete](images/aws_organization_delete.png?raw=true "Oganization delete")

As the above picture suggested I proceeded with removing the non managemet account first. The account I invited was instantenously removed but the one created from within the organization returned the following error.

![Organization account remove error](images/aws_remove_account_from_organization_error.png?raw=true "Organization account remove error")

The missing information were billing information. Once the account is no longer part of the organization it is responsible to pay its own bills. Once entered the credit card details to satisfy the missing billing information, the deletion operation returned a message stating that a wait period is necessary before allowing the account to be removed.

I thought I had to wait some minutes or a couple of hours but it looks like the time to wait is seven days!
The article at 
https://docs.aws.amazon.com/organizations/latest/userguide/orgs_manage_accounts_remove.html?icmpid=docs_orgs_console#leave-without-all-info

reads:

"
**You must wait until at least seven days after the account was created**

To remove an account that you created in the organization, you must wait until at least seven days after the account was created. Invited accounts aren't subject to this waiting period.
"

The organization can be removed when the management account is its only member. From the "AWS Organizarion / Settings new" click on the "Delete organization" button and confirm by typing the organization id in the "Delete organization" window.

![Organization deletion confirmation](images/aws_organization_delete_confirmation.png?raw=true "Organization deletion confirmation")
### Add an Organization from the command line
#### Create an aws cli profile
The first thing to do to add an organization or any other AWS resourse via command line is to authenticate with AWS.

To authenticate we need a profile which can create with the command:
```
aws configure --profile profile-name
```
I specified a profile name, without that the information provided would be added to a default domain.

The command will ask to enter the following:
```
AWS Access Key ID [None]: [20 chars key]
AWS Secret Access Key [None]: [40 chars key]
Default region name [None]: [closest region to you e.g.: ca-central-1]
Default output format [None]: [ one of json (default), yaml, yaml-stream, text, table] 

```
To see the profiles info I issued
```
aws configure list
      Name                    Value             Type    Location
      ----                    -----             ----    --------
   profile                <not set>             None    None
access_key                <not set>             None    None
secret_key                <not set>             None    None
    region                <not set>             None    None
```
but this only lists the default profile, so I used:
```
aws configure --profile profile-name list
      Name                    Value             Type    Location
      ----                    -----             ----    --------
   profile                   profile-name     manual    --profile
access_key     ****************GV3A shared-credentials-file    
secret_key     ****************/pAq shared-credentials-file    
    region             ca-central-1      config-file    ~/.aws/config
```
To see the profile list the command is:
```
aws configure list-profiles
profile-name
```
At this point 2 files containing my account's information have been created in the ~/.aws directory and I can issue commands via cli.

I used the command:
```
aws --profile profile-name s3api list-buckets
```
for a test.

#### Create an aws organization
To create the organization, the command is:
```
aws --profile profile-name organizations create-organization --feature-set ALL
```
N.B.: I specified the profile because I don't have a default profile set. Also the --feature-set parameter is set to the default value and therefore I could have omitted it.

The output of the command is similar to the below:
```
{
    "Organization": {
        "Id": "x-xxxxxxxxxx",
        "Arn": "arn:aws:organizations::111111111111:organization/x-xxxxxxxxxx",
        "FeatureSet": "ALL",
        "MasterAccountArn": "arn:aws:organizations::111111111111:account/x-xxxxxxxxxx/111111111111",
        "MasterAccountId": "111111111111",
        "MasterAccountEmail": "email@domain.tld",
        "AvailablePolicyTypes": [
            {
                "Type": "SERVICE_CONTROL_POLICY",
                "Status": "ENABLED"
            }
        ]
    }
}
```
If I try to run the command again I will receive the error:
```
An error occurred (AlreadyInOrganizationException) when calling the CreateOrganization operation: The AWS account is already a member of an organization.
```
To check if an organization exists I can use the command:
```
aws --profile profile-name organizations describe-organization
```
There are a lot of subcommands for the organizations topic. To repeat what we did from the portal we can use:
```
aws --profile andrea organizations create-account --email rzand+a@hotmail.com --account-name auser
```
we can check the organization's members with:
```
aws --profile andrea organizations list-accounts
```
And invite an existing account with:
```
aws organizations invite-account-to-organization --target '{"Type": "EMAIL", "Id": "email[+x]@domain.tld"}' --notes "This is a request to join ABC organization."
```
I did not try the above command because it would take a lot of time for me to remove the invited account.




## Add AWS IAM Identity Center from the portal
## Add the Control Tower from the portal
