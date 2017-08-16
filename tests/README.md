# Test Instructions

The instructions will show you how to set up the tests for AWS SNS.

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


## Configure the API keys for SNS

At the top of the agent.test.nut there are four constants that need to be configured.

Parameter                   | Description
--------------------------- | -----------
AWS_TEST_REGION             | AWS region (e.g. "us-west-2")
AWS_SNS_ACCESS_KEY_ID       | IAM Access Key ID
AWS_SNS_SECRET_ACCESS_KEY   | IAM Secret Access Key
AWS_SNS_TOPIC_ARN           | Your SNS TOPIC ARN

## Imptest
 Please ensure that the `.imptest` agent file includes both AWSRequestV4 library and the AWSSNS class.

# License

The AWSSQS library is licensed under the [MIT License](../LICENSE).
