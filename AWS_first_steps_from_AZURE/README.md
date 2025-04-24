# Exploring AWS from an Azure background
## Accounts and Accounts' access 
When one signs up for an AWS account he/she will have to specify an email address which will become the root user with all the powers over the account. Best practice suggest to protect that account with MFA, possibly remove its app key and don't use it for ordinary operations. One can create one or more IAM accounts to build infrastructure in the account.

Once logged on with the IAM account one can create resourses in the account. The account is the equivalent of an Azure Resource Group that is a logical container for the resources.

Accounts in AWS are isolated from each other unlike  Resource Groups in Azure and an AWS IAM user cannot access resources in a different account.

With Azure a newly created account can create Azure AD users and each of these users can be granted permissions to access resources in multiple Resourse Groups is grantes the right permissions.

AWS offers structures like Organizations, AWS IAM Identity Center and AWS Control Tower to allow user to access multiple accounts and manage the accounts themselves, I will look into these later.
   
## Add an Account from the portal
First thing I want to see if I can add a new account from the portal using the same email address I used to create my first account and what are the relations between the 2.

I logged on to the portal using the root account and checked the account settings.

to access the account with an IAM account I should reach a url that looks like https://[account_number].signin.aws.amazon.com/console, but I can create an alias for it which would let me access a more memorable https://[alias_name].signin.aws.amazon.com/console.

From withing an account I cannot create another account.

I was able to add a new account un=sing the same email address used to create the first account but I had to add something between the first part of the address and the '@' symbol e.g.:
if the email used for the first account was name.surname@domain.tld the email for the second accound can be name.surname+1@domain.tld

Otherwise I would receive an email stating:
![AWS email](images/aws_email_already_associated_with_an_account.png?raw=true "AWS email")

The 2 accounts have nothing in common apart the email recipient where they will send communications. They cannot see each other and the 2 root accounts have a different credentials: one have to specify the additional characters between the first part of the email and the '@' symbol and a different password.

## Add an Organization from the portal
## All the Control Tower from the portal