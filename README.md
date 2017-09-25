# AWSSNS - Amazon Simple Notification Service Library

The helper library to implement and perform
[Amazon SNS](https://aws.amazon.com/documentation/sns/) actions from agent code.

To add this library to your model, add the following lines to the top of your agent code:

```
#require "AWSRequestV4.class.nut:1.0.2"
#require "AWSSNS.agent.lib.nut:1.0.0"
```

**Note: [AWSRequestV4](https://github.com/electricimp/AWSRequestV4/) must be
included before the AWSSNS library to make it work.**

## Class Usage

### constructor(region, accessKeyId, secretAccessKey)
AWSSNS object constructor which takes the following parameters:

Parameter              | Type           | Description
---------------------- | -------------- | -----------
region                 | string         | AWS region (e.g. "us-west-2")
accessKeyId            | string         | IAM Access Key ID
secretAccessKey        | string         | IAM Secret Access Key

#### Example

```squirrel
const AWS_SNS_ACCESS_KEY_ID     = "YOUR_ACCESS_KEY_ID_HERE";
const AWS_SNS_SECRET_ACCESS_KEY = "YOUR_SECRET_ACCESS_KEY_ID_HERE";
const AWS_SNS_URL               = "YOUR_SNS_URL_HERE";
const AWS_SNS_REGION            = "YOUR_REGION_HERE";

// initialise the class
sns <- AWSSNS(AWS_SNS_REGION, AWS_SNS_ACCESS_KEY_ID, AWS_SNS_SECRET_ACCESS_KEY);
```

## Class Methods

### action(actionType, params, cb)
Performs a specified action (e.g publish) with the
required parameters (`params`) for the specified `action`.

Parameter         |       Type     | Description
----------------- | -------------- | -----------
actionType        | string         | Type of the Amazon SNS action that you want to perform (see [table](#action-types) below for more details)
params            | table          | Table of parameters relevant to the action
cb                | function       | Callback function that takes one parameter (a response table)

#### Action Types

Action Type                                                                             | Description
--------------------------------------------------------------------------------------- | --------------------------------------
[AWSSNS_ACTION_CONFIRM_SUBSCRIPTION](#awssns_action_confirm_subscription)               | Verifies an endpoint owner's intent to receive messages
[AWSSNS_ACTION_LIST_SUBSCRIPTIONS](#awssns_action_list_subscriptions)                   | Returns a xml list of the requester's subscriptions
[AWSSNS_ACTION_LIST_SUBSCRIPTIONS_BY_TOPIC](#awssns_action_list_subscriptions_by_topic) | Returns a xml list of the subscriptions to a specific topic
[AWSSNS_ACTION_LIST_TOPICS](#awssns_action_list_topics)                                 | Returns a xml list of the requester's topics
[AWSSNS_ACTION_PUBLISH](#awssns_action_publish)                                         | Sends a message to an Amazon SNS topic
[AWSSNS_ACTION_SUBSCRIBE](#awssns_action_subscribe)                                     | Prepares to subscribe to an endpoint
[AWSSNS_ACTION_UNSUBSCRIBE](#awssns_action_unsubscribe)                                 | Deletes a subscription

#### Action parameters

#### AWSSNS_ACTION_CONFIRM_SUBSCRIPTION
Verifies an endpoint owner's intent to receive messages by validating the token sent to the endpoint by an earlier Subscribe action.
Please view the [AWS SNS documentation](http://docs.aws.amazon.com/sns/latest/api/API_ConfirmSubscription.html) for more information.

##### Action parameters ([`params`](#actionactiontype-params-cb) argument)
Parameter                 | Type    | Required | Default | Description
------------------------- | ------- | -------- | ------- | -------------------
AuthenticateOnUnsubscribe | string  | No       | null    | Disallows unauthenticated unsubscribes of the subscription. If the value of this parameter is true and the request has an AWS signature, then only the topic owner and the subscription owner can unsubscribe the endpoint. The unsubscribe action requires AWS authentication
Token                     | string  | Yes      | N/A     | Short-lived token sent to an endpoint during the Subscribe action
TopicArn                  | string  | Yes      | N/A     | The ARN of the topic for which you wish to confirm a subscription

##### Confirm Subscription Example
<a id="ida"></a>
```squirrel
http.onrequest(function (request, response) {

    try {

        local requestBody = http.jsondecode(request.body);

        // Handle an SES SubscriptionConfirmation request
        if ("Type" in requestBody && requestBody.Type == "SubscriptionConfirmation") {

            server.log("Received HTTP Request: AWS_SNS SubscriptionConfirmation");

            local confirmParams = {
                "Token": requestBody.Token,
                "TopicArn": requestBody.TopicArn
            };

            sns.action(AWSSNS_ACTION_CONFIRM_SUBSCRIPTION, confirmParams, function (res) {
                server.log("Confirmation Response: " +res.statuscode);
            });
        }

        response.send(200, "OK");

    } catch (exception) {
        server.log("Error handling HTTP request: " + exception);
        response.send(500, "Internal Server Error: " + exception);
    }

});
```

#### AWSSNS_ACTION_LIST_SUBSCRIPTIONS
Returns a xml list of the requester's subscriptions as a string in the response table.
Please view the [AWS SNS documentation](http://docs.aws.amazon.com/sns/latest/api/API_ListSubscriptions.html) for more information.

##### Action parameters ([`params`](#actionactiontype-params-cb) argument)
Parameter                 | Type    | Required | Default | Description
------------------------- | ------- | -------- | ------- | -------------------
NextToken                 | string  | No       | null    | Token returned by the previous *ListSubscriptions* request.

##### List Subscriptions Example

```squirrel
sns.action(AWSSNS_ACTION_LIST_SUBSCRIPTIONS, {}, function (res) {
    // do something with res.body the returned xml
});
```

#### AWSSNS_ACTION_LIST_SUBSCRIPTIONS_BY_TOPIC
Returns a xml list of the subscriptions to a specific topic as a string in the response table.
Please view the [AWS SNS documentation](http://docs.aws.amazon.com/sns/latest/api/API_ListSubscriptionsByTopic.html) for more information.

##### Action parameters ([`params`](#actionactiontype-params-cb) argument)
Parameter                 | Type    | Required | Default | Description
------------------------- | ------- | -------- | ------- |  ------------------
NextToken                 | string  | No       | null    | Token returned by the previous *ListSubscriptionsByTopic* request
TopicArn                  | string  | Yes      | N/A     | The ARN of the topic for which you wish to confirm a subscription

##### List Subscriptions By Topic Example

```squirrel
// find the endpoint in the response that corresponds to ARN
local endpointFinder = function (messageBody) {

    local endpoint = http.agenturl();
    local start = messageBody.find(endpoint);
    start = start + endpoint.len();
    return start;
};

// finds the SubscriptionArn corresponding to the specified endpoint
local subscriptionFinder = function (messageBody, startIndex) {

    local start = messageBody.find(AWS_SNS_SUBSCRIPTION_ARN_START, startIndex);
    local finish = messageBody.find(AWS_SNS_SUBSCRIPTION_ARN_FINISH, startIndex);
    local subscription = messageBody.slice((start + 17), (finish));
    return subscription;
};

local params = {
    "TopicArn": "YOUR_TOPIC_ARN_HERE"
};

sns.action(AWSSNS_ACTION_LIST_SUBSCRIPTIONS_BY_TOPIC, params, function (res) {

    // finds your specific subscriptionArn
    local subscriptionArn = subscriptionFinder(res.body, endpointFinder(res.body));
});
```

#### AWSSNS_ACTION_LIST_TOPICS
Returns a xml list of the requester's topics as a string in the response table.
Please view the [AWS SNS documentation](http://docs.aws.amazon.com/sns/latest/api/API_ListTopics.html) for more information.

##### Action parameters ([`params`](#actionactiontype-params-cb) argument)
Parameter                 | Type    | Required | Default | Description
------------------------- | ------- | -------- | ------- | --------------------
NextToken                 | string  | No       | null    | Token returned by the previous ListTopics request.

##### List Topics Example

```squirrel
sns.action(AWSSNS_ACTION_LIST_TOPICS, {}, function (res) {

    // do something with res.body the returned xml
})
```

#### AWSSNS_ACTION_PUBLISH
Sends a message to an Amazon SNS topic or sends a text message (SMS message) directly to a phone number.
Please view the [AWS SNS documentation](http://docs.aws.amazon.com/sns/latest/api/API_Publish.html) for more information.

##### Action parameters ([`params`](#actionactiontype-params-cb) argument)
Parameter                | Type    | Required | Default | Description
------------------------ | ------- | -------- | ------- | -------------------
Message                  | string  | Yes      | N/A     | The message you want to send
MessageAttributes        | table   | No       | null    | MessageAttributes.entry.N.Name (key), MessageAttributesentry.N.Value (value) pairs. see MessageAttributeValue table for more information
MessageStructure         | string  | No       | null    | Set MessageStructure to json if you want to send a different message for each protocol
PhoneNumber              | string  | No       | null    | The phone number to which you want to deliver an SMS message
Subject                  | string  | No       | null    | Optional parameter to be used as the "Subject" line when the message is delivered to email endpoints
TargetArn                | string  | No       | null    | either TopicArn or EndpointArn, but not both
TopicArn                 | string  | No       | null    | The topic you want to publish to

Note : You need at least one of TopicArn, PhoneNumber or TargetArn parameters.

where `MessageAttributes` consists of:

Parameter                | Type                              | Required | Default | Description
------------------------ | --------------------------------  | -------- | ------- | -------------------
BinaryValue              | base64-encoded binary data object | No       | null    | Binary type attributes can store any binary data, for example, compressed data, encrypted data, or images
DataType                 | string                            | Yes      | N/A     | Amazon SNS supports the following logical data types: String, Number, and Binary
StringValue              | string                            | No       | null    | Strings are Unicode with UTF8 binary encoding

##### Publish Example

```squirrel
local params = {
    "Message": "Hello World",
    "TopicArn": AWS_SNS_TOPIC_ARN
};

sns.action(AWSSNS_ACTION_PUBLISH, params, function (res) {
    // check the status code for a successful publish res.statuscode
});

```

#### AWSSNS_ACTION_SUBSCRIBE
Prepares to subscribe to an endpoint by sending the endpoint a confirmation message.
Please view the [AWS SNS documentation](http://docs.aws.amazon.com/sns/latest/api/API_Subscribe.html) for more information.

##### Action parameters ([`params`](#actionactiontype-params-cb) argument)
Parameter                | Type    | Required | Default | Description
------------------------ | ------- | -------- | ------- | -------------------
Endpoint                 | string  | No       | null    | The endpoint that you want to receive notifications. Endpoints vary by protocol
Protocol                 | string  | Yes      | N/A     | The protocol you want to use. Supported protocols include: http, https, email, email-json, sms, sqs, application and lambda
TopicArn                 | string  | Yes      | N/A     | The topic you want to publish to

##### Subscribe Example

```squirrel
subscribeParams <- {
    "Protocol": "https",
    "TopicArn": "YOUR_TOPIC_ARN_HERE",
    "Endpoint": http.agenturl()
};

sns.action(AWSSNS_ACTION_SUBSCRIBE, subscribeParams, function (res) {
    server.log("Subscribe Response: " + http.jsonencode(res));
});
```

#### AWSSNS_ACTION_UNSUBSCRIBE
Deletes a subscription.
Please view the [AWS SNS documentation](http://docs.aws.amazon.com/sns/latest/api/API_Unsubscribe.html) for more information.

##### Action parameters ([`params`](#actionactiontype-params-cb) argument)
Parameter                | Type    | Required | Description
------------------------ | ------- | -------- | --------------------------
SubscriptionArn          | string  | Yes      | The ARN of the subscription to be deleted


##### Unsubscribe Example
See ConfirmSubscription [example](#ida) as to how to get a value for SubscriptionArn

```squirrel
local params = {
    "SubscriptionArn": YOUR_SUBSCRIPTION_ARN
};

sns.action(AWSSNS_ACTION_UNSUBSCRIBE, params, function(res) {
    server.log("Unsubscribe Response: " + http.jsonencode(res));
});
```

### Response Table
The format of the response table general to all functions

Parameter             |       Type     | Description
--------------------- | -------------- | -----------
body                  | string         | AWS SNS response in a XML data structure which is received as a string.
statuscode            | integer        | http status code
headers               | table          | see headers

where `headers` table consists of:


Parameter             |       Type     | Description
--------------------- | -------------- | -----------
x-amzn-requestid      | string         | Amazon request id
content-type          | string         | Content type e.g text/XML
date                  | string         | The date and time at which response was sent
content-length        | string         | the length of the content

# License

The AWSSNS library is licensed under the [MIT License](LICENSE).
