# Exploring AWS from an Azure background (sharing my beginner understanding of AWS)
## Accounts and Accounts' access 
The first things I considered when I started working with AWS was where to create the resources and how to access them, concious that for cloud security identity access and management is paramount. 

When one signs up for an AWS account he/she will have to specify an email address which will become the root user with all the powers over the account. Best practice suggests to protect that account with MFA, possibly remove its app key and don't use it for ordinary operations. One can create one or more IAM accounts to build infrastructure in the account.

Once created an IAM user and and logged on with it, one can create resources in the account providing the user has the correct role/permission. The account is the equivalent of an Azure Resource Group or even a subscription. They are a logical containers for the resources.

Accounts in AWS are isolated from each other, Azure's Resource Groups are not. This means that an AWS IAM user cannot access resources in different accounts, while an Azure user can access resources in different Resource Groups provided that it has the correct RBAC (role based access control) permission.

AWS offers structures like Organizations, AWS IAM Identity Center and AWS Control Tower to allow users to access multiple accounts and manage the accounts themselves, I will look into these later.
   
## Add an Account from the portal
First thing I want to see if adding a new account from the portal using the same email address I used to create my first account can build some inter-account visibility.

I logged on to the portal using the root account and checked the account settings.

To access the account with an IAM account I should reach a url that looks like https://[account_number].signin.aws.amazon.com/console, but I can create an alias (from the IAM service dashbord link) for it which would let me access a more memorable https://[alias_name].signin.aws.amazon.com/console.

From within an account I cannot create another account.

To add a new account using a previously used email address I had to add add a + symbol and something between the first part of the address and the '@' symbol e.g.:
if the email used for the first account was name.surname@domain.tld the email for the second account can be name.surname+1@domain.tld

Otherwise I would receive an email stating:
![AWS email](images/aws_email_already_associated_with_an_account.png?raw=true "AWS email")

Once a created the second account, I realized that the 2 accounts created using the same email address have nothing in common apart the email recipient where they will send communications to. They cannot see each other and the 2 root accounts have a different credentials. One has to specify the + symbol and the additional characters between the first part of the email and the '@' symbol and a different password to access the second account generated with a common email.

## Add an Organization from the portal
To manage more accounts - which we can think as resources' containers - from the same user I need to build an organization.

I logged on as my root account and searched for organization in the AWS console.

![AWS email](images/aws_console_search_organization.png?raw=true "Search for organization")

Clicked "AWS Organizations" under services and clicked the "Create an organization button"

![Create an organization button](images/aws_create_organization.png?raw=true "Create an organization button")

This web page also provide very useful help and information. I personally like the succint way the AWS help is provided.

Upon creating an organization we are reminded that the account from which we are operating will become the managrmrnt account for the organization.

![Organization management account](images/aws_organization_management_account.png?raw=true "Organization management account")

The important thing here is that governance policies don't apply to the management account and so it is best practice not to build resources in this account. 

See https://docs.aws.amazon.com/organizations/latest/userguide/orgs_best-practices_mgmt-acct.html for more best practices.

![Organization created](images/aws_organization_created.png?raw=true "Organization created")

Creating the organization is quick. As soon as the organization is created we can add accounts simply clicking a button.

![Manage organization accounts](images/aws_add_an_account_to_an_organization.png?raw=true "Manage organization accounts")

I invited the account I created using the same email address of the management account. To do so I had to use the account id in the invitation since the email address with the added + symbel and characters before the @ symbol did not work.

I received an email with the invitation and a link but - because of the common email address - to accept the invitation I had to log on to the invited account console using its the root user, moved to the "AWS Organization" section and clicked on the "View 1 invitation" button.

![Oganization invitation received](images/aws_organization_invitation_received.png?raw=true "Oganization invitation received")

and then accept the invitation.

![Oganization invitation accepted](images/aws_organization_invitation_accepted.png?raw=true "Oganization invitation accepted")

I also created an account from within the organization. Since I wanted to use the same email address used to create the previous accounts, I had to add a + symbol and few characters before the @ symbol for the email of the root account. To set the password for the account I clicked the link for the forgotten password on the console login screen.

I now can see 3 account listed in the organization if I log on to the aws console with management account root user (or IAM Admin user) and navigate to the "AWS Organizations" service.

Logging on to the console with the root credentials for the other accounts that are member of the organization and navigating to the "AWS Organizations" service I am able to see the organization id of which the account is a member.

Each of these accounts have their own root user, it is recommended to centralize the root user and remove the root credentials of all the accounts other than the management one.

At https://docs.aws.amazon.com/IAM/latest/UserGuide/id_root-enable-root-access.html AWS provides good documentation about how to centralize the root account.

Before looking at that I want to try and remove the organization and recreate it via command line.

## Remove an Organization from the portal

To remove the organization I logged on the management account with the root usernd navigate to the "AWS Organizations" service "Settings new" link.

![Oganization delete](images/aws_organization_delete.png?raw=true "Oganization delete")

As the above picture suggested I proceeded with removing the non managemet account first. The account I invited was instantenously removed but the one created from within the organization returned the following error.

![Organization account remove error](images/aws_remove_account_from_organization_error.png?raw=true "Organization account remove error")

The missing information were billing information. Once the account is no longer part of the organization it is responsible to pay its own bills. Once entered the credit card details the operation required a wait period before allowing the account to be removed.



## Add AWS IAM Identity Centerfrom the portal
## Add the Control Tower from the portal