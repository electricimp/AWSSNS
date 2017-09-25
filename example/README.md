# Demo Instructions

This demo will show you how to subscribe, confirm a subscription and publish a message to a topic

As the sample code includes the private key verbatim in the source, it should be treated carefully, and not checked into version control!


## Setting up a Topic in AWS SNS

1. Login to the [AWS console](https://aws.amazon.com/console/)
1. Select `Services link` (on the top left of the page) and then type `SNS` in the search line
1. Select `Simple Notification Service`
1. Click `Create Topic`
1. Enter in `Topic name` "testSNS"
1. Enter in `DisplayName` "testSNS"
1. Click `Create Topic`
1. Note your Topic ARN and your Region

## Setting up IAM Policy

1. Select `Services` link (on the top left of the page) and them type `IAM` in the search line
1. Select `IAM Manage User Access and Encryption Keys` item
1. Select `Policies` item from the menu on the left
1. Press `Create Policy` button
1. Press `Select` for `Policy Generator`
1. On the `Edit Permissions` page do the following
    1. Set `Effect` to `Allow`
    1. Set `AWS Service` to `Amazon SNS`
    1. Set `Actions` to `All Actions`
    1. Set `Amazon Resource Name (ARN)` to Topic ARN from **Setting up a Topic in AWS SNS**
    1. Press `Add Statement`
    1. Press `Next Step`
1. Give your policy a name, for example, `allow-sns` and type in into the `Policy Name` field
1. Press `Create Policy`

## Setting up the IAM User

1. Select `Services` link (on the top left of the page) and them type `IAM` in the search line
1. Select the `IAM Manage User Access and Encryption Keys` item
1. Select `Users` item from the menu on the left
1. Press `Add user`
1. Choose a user name, for example `user-calling-sns`
1. Check `Programmatic access` but not anything else
1. Press `Next: Permissions` button
1. Press `Attach existing policies directly` icon
1. Check `allow-sns` from the list of policies
1. Press `Next: Review`
1. Press `Create user`
1. Copy down your `Access key ID` and `Secret access key`

## Configure the API keys for SNS

At the top of the sample.agent.nut there are three constants that need to be configured.

Parameter                   | Description
--------------------------- | -----------
AWS_TEST_REGION             | AWS region (e.g. "us-west-2")
AWS_SNS_ACCESS_KEY_ID       | IAM Access Key ID
AWS_SNS_SECRET_ACCESS_KEY   | IAM Secret Access Key
AWS_SNS_TOPIC_ARN           | Your SNS TOPIC ARN


The AWSSNS library is licensed under the [MIT License](../LICENSE).
