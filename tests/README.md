# Test Instructions #

The instructions will show you how to set up the tests for AWS SNS.

As the sample code includes the private key verbatim in the source, it should be treated carefully, and not checked into version control!

## Set Up A Topic In AWS SNS ##

1. Login to the [AWS console](https://aws.amazon.com/console/).
1. Select **Services link** (on the top left of the page) and then type `SNS` in the search line.
1. Select **Simple Notification Service**.
1. Click **Create Topic**.
1. Enter `testSNS` under **Topic name**.
1. Enter `testSNS` under **DisplayName**.
1. Click **Create Topic*.
1. Note your Topic ARN and your Region.

## Set Up An IAM Policy ##

1. Select the **Services** link (on the top left of the page) and them type `IAM` in the search line.
1. Select the **IAM Manage User Access and Encryption Keys** item.
1. Select the **Policies** item from the menu on the left.
1. Click **Create Policy**.
1. Click **Select** under **Policy Generator**.
1. On the **Edit Permissions** page do the following:
    1. Set **Effect** to **Allow**.
    1. Set **AWS Service** to **Amazon SNS**.
    1. Set **Actions** to **All Actions**.
    1. Set **Amazon Resource Name (ARN)** to **&#42;**.
    1. Click **Add Statement**.
    1. Click **Next Step**.
1. Give your policy a name, for example, `allow-sns` and type in into the **Policy Name** field.
1. Click **Create Policy**.

## Set Up An IAM User ##

1. Select the **Services** link (on the top left of the page) and them type `IAM` in the search line.
1. Select the **IAM Manage User Access and Encryption Keys** item.
1. Select the **Users** item from the menu on the left.
1. Click **Add user**.
1. Choose a user name, for example `user-calling-sns`.
1. Check **Programmatic access** but not anything else.
1. Click **Next: Permissions**
1. Click the **Attach existing policies directly** icon.
1. Check **allow-sns** from the list of policies.
1. Click **Next: Review**.
1. Click **Create user**.
1. Note your Access key ID and Secret access key values.

## Configure The API Keys For SNS ##

At the top of the `agent.test.nut` file there are four constants that need to be configured:

Constant                      | Description
----------------------------- | -----------
*AWS_TEST_REGION*             | An AWS region (eg. `"us-west-2"`)
*AWS_SNS_ACCESS_KEY_ID*       | Your IAM Access Key ID
*AWS_SNS_SECRET_ACCESS_KEY*   | Your IAM Secret Access Key
*AWS_SNS_TOPIC_ARN*           | Your SNS TOPIC ARN

## Imptest ##

Please ensure that the `.imptest` agent file includes both the AWSRequestV4 library and the AWSSNS library.
