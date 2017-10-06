# AWSSNS &mdash; Amazon Simple Notification Service Library

This library implements [Amazon Simple Notification Service (SNS)](https://aws.amazon.com/documentation/sns/) actions in agent code.

**To add this library to your application, add the following lines to the top of your agent code:**

```
#require "AWSRequestV4.class.nut:1.0.2"
#require "AWSSNS.agent.lib.nut:1.0.0"
```

**Note** [AWSRequestV4](https://github.com/electricimp/AWSRequestV4/) must be included **before** the AWSSNS library.

## Class Usage

### constructor(*region, accessKeyID, secretAccessKey*)

The constructor takes the following parameters, all of which are required:

Parameter              | Type           | Description
---------------------- | -------------- | -----------
*region*                 | string         | AWS region (eg. `"us-west-2"`)
*accessKeyId*            | string         | IAM Access Key ID
*secretAccessKey*        | string         | IAM Secret Access Key

#### Example

```squirrel
const AWS_SNS_ACCESS_KEY_ID     = "<YOUR_ACCESS_KEY_ID>";
const AWS_SNS_SECRET_ACCESS_KEY = "<YOUR_SECRET_ACCESS_KEY_ID>";
const AWS_SNS_URL               = "<YOUR_SNS_URL>";
const AWS_SNS_REGION            = "<YOUR_REGION>";

// Instantiate the class
sns <- AWSSNS(AWS_SNS_REGION, AWS_SNS_ACCESS_KEY_ID, AWS_SNS_SECRET_ACCESS_KEY);
```

## Class Methods

### action(*actionType, params, callback*)

This method performs a specified action (eg. publish) with the required parameters (*params*) for the specified action type.

Parameter         |       Type     | Description
----------------- | -------------- | -----------
*actionType*       | Constant         | The type of the Amazon SNS action that you want to perform (see ‘Action Types’, below)
*params*            | Table          | Table of action-specific parameters (see ‘Action Parameters’, below)
*callback*            | Function       | Callback function that takes one parameter: a [Callback Response Table](#callback-response-table)

#### Action Types

Action Type                                                                             | Description
--------------------------------------------------------------------------------------- | --------------------------------------
[*AWSSNS_ACTION_CONFIRM_SUBSCRIPTION*](#awssns_action_confirm_subscription)               | Verifies an endpoint owner’s intent to receive messages
[*AWSSNS_ACTION_LIST_SUBSCRIPTIONS*](#awssns_action_list_subscriptions)                   | Returns an XML list of the requester’s subscriptions
[*AWSSNS_ACTION_LIST_SUBSCRIPTIONS_BY_TOPIC*](#awssns_action_list_subscriptions_by_topic) | Returns an XML list of the subscriptions to a specific topic
[*AWSSNS_ACTION_LIST_TOPICS*](#awssns_action_list_topics)                                 | Returns an XML list of the requester’s topics
[*AWSSNS_ACTION_PUBLISH*](#awssns_action_publish)                                         | Sends a message to an Amazon SNS topic
[*AWSSNS_ACTION_SUBSCRIBE*](#awssns_action_subscribe)                                     | Prepares to subscribe to an endpoint
[*AWSSNS_ACTION_UNSUBSCRIBE*](#awssns_action_unsubscribe)                                 | Deletes a subscription

#### Action Parameters

Specific actions of the types listed above are configured by passing information into *action()*’s *params* parameter as a table with the following action type-specific keys.

#### AWSSNS_ACTION_CONFIRM_SUBSCRIPTION

Verifies an endpoint owner’s intent to receive messages by validating the token sent to the endpoint by an earlier Subscribe action. Please view the [AWS SNS documentation](http://docs.aws.amazon.com/sns/latest/api/API_ConfirmSubscription.html) for more information.

Parameter                 | Type    | Required | Default | Description
------------------------- | ------- | -------- | ------- | -------------------
*AuthenticateOnUnsubscribe* | String  | No       | `null`    | Disallows unauthenticated unsubscribes of the subscription. If the value of this parameter is `true` and the request has an AWS signature, then only the topic owner and the subscription owner can unsubscribe the endpoint. The unsubscribe action requires AWS authentication
*Token*                     | String  | Yes      | N/A     | Short-lived token sent to an endpoint during the Subscribe action
*TopicArn*                  | String  | Yes      | N/A     | The ARN of the topic for which you wish to confirm a subscription

<h5 id="ida">Example</h5>

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

Returns an XML list of the requester’s subscriptions as a string in the response table. Please view the [AWS SNS documentation](http://docs.aws.amazon.com/sns/latest/api/API_ListSubscriptions.html) for more information.

Parameter                 | Type    | Required | Default | Description
------------------------- | ------- | -------- | ------- | -------------------
*NextToken*                 | String  | No       | `null`    | Token returned by the previous ListSubscriptions request

##### Example #####

```squirrel
sns.action(AWSSNS_ACTION_LIST_SUBSCRIPTIONS, {}, function (response) {
    // Do something with the returned XML
});
```

#### AWSSNS_ACTION_LIST_SUBSCRIPTIONS_BY_TOPIC

Returns an XML list of the subscriptions to a specific topic as a string in the response table. Please view the [AWS SNS documentation](http://docs.aws.amazon.com/sns/latest/api/API_ListSubscriptionsByTopic.html) for more information.

Parameter                 | Type    | Required | Default | Description
------------------------- | ------- | -------- | ------- |  ------------------
*NextToken*                 | String  | No       | `null` | Token returned by the previous ListSubscriptionsByTopic request
*TopicArn*                  | String  | Yes      | N/A     | The ARN of the topic for which you wish to confirm a subscription

##### Example #####

```squirrel
// Find the endpoint in the response that corresponds to ARN
local endpointFinder = function (messageBody) {
    local endpoint = http.agenturl();
    local start = messageBody.find(endpoint);
    start = start + endpoint.len();
    return start;
};

// Finds the SubscriptionArn corresponding to the specified endpoint
local subscriptionFinder = function (messageBody, startIndex) {
    local start = messageBody.find(AWS_SNS_SUBSCRIPTION_ARN_START, startIndex);
    local finish = messageBody.find(AWS_SNS_SUBSCRIPTION_ARN_FINISH, startIndex);
    local subscription = messageBody.slice((start + 17), (finish));
    return subscription;
};

local params = {
    "TopicArn": "YOUR_TOPIC_ARN_HERE"
};

sns.action(AWSSNS_ACTION_LIST_SUBSCRIPTIONS_BY_TOPIC, params, function (response) {
    // Finds your specific subscription ARN
    local subscriptionArn = subscriptionFinder(response.body, endpointFinder(response.body));
});
```

#### AWSSNS_ACTION_LIST_TOPICS

Returns an XML list of the requester’s topics as a string in the response table. Please view the [AWS SNS documentation](http://docs.aws.amazon.com/sns/latest/api/API_ListTopics.html) for more information.

Parameter                 | Type    | Required | Default | Description
------------------------- | ------- | -------- | ------- | --------------------
*NextToken*                 | String  | No       | `null`  | Token returned by the previous ListTopics request

##### Example #####

```squirrel
sns.action(AWSSNS_ACTION_LIST_TOPICS, {}, function (response) {
    // Do something the returned XML
})
```

#### AWSSNS_ACTION_PUBLISH

Sends a message to an Amazon SNS topic or sends a text message (SMS message) directly to a phone number. Please view the [AWS SNS documentation](http://docs.aws.amazon.com/sns/latest/api/API_Publish.html) for more information.

Parameter                | Type    | Required | Default | Description
------------------------ | ------- | -------- | ------- | -------------------
*Message*                  | String  | Yes      | N/A     | The message you want to send
*MessageAttributes*        | Table   | No       | `null`    | *MessageAttributes.entry.N.Name* (key), *MessageAttributesentry.N.Value* (value) pairs. see the ‘MessageAttributes Values’ table, below, for more information
*MessageStructure*         | String  | No       | `null`    | Set message structure to JSON if you want to send a different message for each protocol
*PhoneNumber*              | String  | No       | `null`    | The phone number to which you want to deliver an SMS message
*Subject*                  | String  | No       | `null`    | Optional parameter to be used as the ‘Subject’ line when the message is delivered to email endpoints
*TargetArn*                | String  | No       | `null`    | Either TopicArn or EndpointArn, but not both
*TopicArn*                | String  | No       | `null`    | The topic you want to publish to

**Note** You need at least one of the *TopicArn*, *PhoneNumber* or *TargetArn* parameters.

#### MessageAttributes Values ####

Key                | Type                              | Required | Default | Description
------------------------ | --------------------------------  | -------- | ------- | -------------------
*BinaryValue*              | Base64-encoded binary data object | No       | `null`    | Binary type attributes can store any binary data, for example, compressed data, encrypted data or images
*DataType*                 | String                            | Yes      | N/A     | Amazon SNS supports the following logical data types: String, Number and Binary
*StringValue*              | String                            | No       | null    | Strings are Unicode with UTF8 binary encoding

##### Example #####

```squirrel
local params = {
    "Message": "Hello World",
    "TopicArn": AWS_SNS_TOPIC_ARN
};

sns.action(AWSSNS_ACTION_PUBLISH, params, function (response) {
    // Check the status code (response.statuscode) for a successful publish
});
```

#### AWSSNS_ACTION_SUBSCRIBE

Prepares to subscribe to an endpoint by sending the endpoint a confirmation message. Please view the [AWS SNS documentation](http://docs.aws.amazon.com/sns/latest/api/API_Subscribe.html) for more information.

Parameter                | Type    | Required | Default | Description
------------------------ | ------- | -------- | ------- | -------------------
*Endpoint*                 | String  | No       | `null` | The endpoint that you want to receive notifications. Endpoints vary by protocol
*Protocol*                 | String  | Yes      | N/A     | The protocol you want to use. Supported protocols include: HTTP, HTTPS, email, email-JSON, SMS, SQS, application and lambda
*TopicArn*                 | String  | Yes      | N/A     | The topic you want to publish to

##### Example #####

```squirrel
subscribeParams <- {
    "Protocol": "https",
    "TopicArn": "YOUR_TOPIC_ARN_HERE",
    "Endpoint": http.agenturl()
};

sns.action(AWSSNS_ACTION_SUBSCRIBE, subscribeParams, function (response) {
    server.log("Subscribe Response: " + http.jsonencode(response));
});
```

#### AWSSNS_ACTION_UNSUBSCRIBE

Deletes a subscription. Please view the [AWS SNS documentation](http://docs.aws.amazon.com/sns/latest/api/API_Unsubscribe.html) for more information.

Parameter                | Type    | Required | Description
------------------------ | ------- | -------- | --------------------------
*SubscriptionArn*          | String  | Yes      | The ARN of the subscription to be deleted


##### Example #####

See the ConfirmSubscription [example](#ida) to see how to get a value for *SubscriptionArn*.

```squirrel
local params = {
    "SubscriptionArn": YOUR_SUBSCRIPTION_ARN
};

sns.action(AWSSNS_ACTION_UNSUBSCRIBE, params, function(response) {
    server.log("Unsubscribe Response: " + http.jsonencode(response));
});
```

### Callback Response Table ###

The response table general to all functions contains the following keys:

Key             |       Type     | Description
--------------------- | -------------- | -----------
*body*                  | String         | AWS SNS response in an XML data structure which is received as a string
*statuscode*            | Integer        | An HTTP status code
*headers*               |Table          | See ‘Headers’, below

#### Headers

The *headers* key’s value is itself a table, with the following keys:

Key             |       Type     | Description
--------------------- | -------------- | -----------
*x-amzn-requestid*      | String         | The Amazon request ID
*content-type*          | String         | The Content type eg. `text/XML`
*date*                 | String         | The date and time at which the response was sent
*content-length*        | String         | The length of the response content

# License

The AWSSNS library is licensed under the [MIT License](LICENSE).
