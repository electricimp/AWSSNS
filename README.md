# AWSSNS

To add this library to your model, add the following lines to the top of your agent code:

```
#require "AWSRequestV4.class.nut:1.0.2"
#require "AWSSNS.lib.nut:1.0.0"
```

**Note: [AWSRequestV4](https://github.com/electricimp/AWSRequestV4/) must be loaded.**

Amazon SNS is a fully managed pub/sub messaging service that makes it easy to decouple and scale microservices, distributed systems, and serverless applications. With SNS, you can use topics to decouple message publishers from subscribers, fan-out messages to multiple recipients at once, and eliminate polling in your applications.
This class can be used to perform actions on the AWS SNS service.




## Class Methods

### constructor(region, accessKeyId, secretAccessKey)

All parameters are strings. Access keys can be generated with IAM.

#### Example

```squirrel
const AWS_SNS_ACCESS_KEY_ID = "YOUR_KEY_ID_HERE";
const AWS_SNS_REGION = "YOUR_REGION_HERE";
const AWS_SNS_SECRET_ACCESS_KEY = "YOUR_KEY_HERE";
const AWS_SNS_TOPIC_ARN "YOUR AWS SNS TOPIC ARN HERE";

sns <- AWSSNS(AWS_REGION, AWS_ACCESS_KEY_ID, AWS_SECRET_ACCESS_KEY);

```



### ConfirmSubscription(params, cb)
Verifies an endpoint owner's intent to receive messages by validating the token sent to the endpoint by an earlier Subscribe action.
For more information see: [here](http://docs.aws.amazon.com/sns/latest/api/API_ConfirmSubscription.html)

 Parameter 	           |       Type     | Description
---------------------- | -------------- | -----------
**params**             | table          | Table of parameters (See API Reference)
**cb**                 | function       | Callback function that takes one parameter (a response table)

where `params` includes

 Parameter 	              | Type    | Required | Default | Description             
------------------------- | ------- | -------- | ------- | -------------------
AuthenticateOnUnsubscribe | String  | No       | null    | Disallows unauthenticated unsubscribes of the subscription. If the value of this parameter is true and the request has an AWS signature, then only the topic owner and the subscription owner can unsubscribe the endpoint. The unsubscribe action requires AWS authentication
Token					  | String  | Yes      | N/A     | Short-lived token sent to an endpoint during the Subscribe action
TopicArn                  | String  | Yes      | N/A     | The ARN of the topic for which you wish to confirm a subscription

#### Example
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
            }
            sns.ConfirmSubscription(confirmParams, function (res) {

                server.log("Confirmation Response: " +res.statuscode);                
            });
        }
        response.send(200, "OK");

    } catch (exception) {
        server.log("Error handling HTTP request: " + exception);
        response.send(500, "Internal Server Error: " + exception);
    }

})
```



### ListSubscriptions(params, cb)
Returns a xml list of the requester's subscriptions as a string in the response table.
For more information see: [here](http://docs.aws.amazon.com/sns/latest/api/API_ListSubscriptions.html)

 Parameter 	           | Type  		    | Description
---------------------- | -------------- | -----------
**params**             | table          | Table of parameters (See API Reference)
**cb**                 | function       | Callback function that takes one parameter (a response table)

where `params` includes

Parameter 	              | Type    | Required | Default | Description             
------------------------- | ------- | -------- | ------- | -------------------
NextToken				  | String	| No	   | null    | Token returned by the previous *ListSubscriptions* request.



#### Example

```squirrel
sns.ListSubscriptions({}, function (res){

    // do something with res.body the returned xml
})
```



### ListSubscriptionsByTopic(params, cb)
Returns a xml list of the subscriptions to a specific topic as a string in the response table.
For more information see: [here](http://docs.aws.amazon.com/sns/latest/api/API_ListSubscriptionsByTopic.html)

 Parameter             |       Type     | Description
---------------------- | -------------- | -----------
**params**             | table          | Table of parameters (See API Reference)
**cb**                 | function       | Callback function that takes one parameter (a response table)

where `params` includes

Parameter	              | Type    | Required | Default | Description             
------------------------- | ------- | -------- | ------- |  ------------------
NextToken				  | String	| No	   | null    | Token returned by the previous *ListSubscriptionsByTopic* request
TopicArn				  | String  | Yes      | N/A     | The ARN of the topic for which you wish to confirm a subscription



#### Example

```squirrel
// find the endpoint in the response that corresponds to ARN
local endpointFinder = function (messageBody) {

    local endpoint = http.agenturl();
    local start = messageBody.find(endpoint);
    start = start + endpoint.len();
    return start;
}

// finds the SubscriptionArn corresponding to the specified endpoint
local subscriptionFinder = function (messageBody, startIndex) {

    local start = messageBody.find(AWS_SNS_SUBSCRIPTION_ARN_START, startIndex);
    local finish = messageBody.find(AWS_SNS_SUBSCRIPTION_ARN_FINISH, startIndex);
    local subscription = messageBody.slice((start + 17), (finish));
    return subscription;
}

local Params = {
    "TopicArn": "YOUR_TOPIC_ARN_HERE"
}

sns.ListSubscriptionsByTopic(Params, function (res) {

    // finds your specific subscriptionArn
    local subscriptionArn == subscriptionFinder(res.body, endpointFinder(res.body))

})
```



### ListTopics(params, cb)
Returns a xml list of the requester's topics as a string in the response table.
For more information see: [here](http://docs.aws.amazon.com/sns/latest/api/API_ListTopics.html)

 Parameter         	   |       Type     | Description
---------------------- | -------------- | -----------
**params**             | table          | Table of parameters (See API Reference)
**cb**                 | function       | Callback function that takes one parameter (a response table)

where `params` includes

Parameter                 | Type    | Required | Default | Description             
------------------------- | ------- | -------- | ------- | --------------------
NextToken				  | String	| No	   | null    | Token returned by the previous ListTopics request.




#### Example

```squirrel
sns.ListTopics({}, function (res) {

    // do something with res.body the returned xml
})
```



### Publish(params, cb)
Sends a message to an Amazon SNS topic or sends a text message (SMS message) directly to a phone number.
For more information see: [here](http://docs.aws.amazon.com/sns/latest/api/API_Publish.html)

 Parameter             |       Type     | Description
---------------------- | -------------- | -----------
**params**             | table          | Table of parameters (See API Reference)
**cb**                 | function       | Callback function that takes one parameter (a response table)

where `params` includes

Parameter                | Type    | Required | Default | Description             
------------------------ | ------- | -------- | ------- | -------------------
Message 				 | String  | Yes	  | N/A     | The message you want to send
MessageAttributes		 | String  | No 	  | null    | MessageAttributes.entry.N.Name (key), MessageAttributesentry.N.Value (value) pairs. see MessageAttributeValue table for more information
MessageStructure		 | String  | No 	  | null    | Set MessageStructure to json if you want to send a different message for each protocol
PhoneNumber				 | String  | No 	  | null    | The phone number to which you want to deliver an SMS message
Subject					 | String  | No 	  | null    | Optional parameter to be used as the "Subject" line when the message is delivered to email endpoints
TargetArn				 | String  | No 	  | null    | either TopicArn or EndpointArn, but not both
TopicArn				 | String  | No 	  | null    | The topic you want to publish to

Note : You need at least one of TopicArn, PhoneNumber or TargetArn parameters.

#### MessageAttributeValue

Parameter                | Type    						 	 | Required | Default | Description             
------------------------ | --------------------------------  | -------- | ------- | -------------------
BinaryValue				 | Base64-encoded binary data object | No		| null    | Binary type attributes can store any binary data, for example, compressed data, encrypted data, or images
DataType			     | String	 						 | Yes		| N/A     | Amazon SNS supports the following logical data types: String, Number, and Binary
StringValue				 | String		  					 | No		| null    | Strings are Unicode with UTF8 binary encoding



#### Example

```squirrel
local params = {
    "Message": "Hello World",
    "TopicArn": AWS_SNS_TOPIC_ARN,
}

sns.Publish(params, function (res) {
    // check the status code for a successful publish res.statuscode
})

```



### Subscribe(params, cb)
Prepares to subscribe an endpoint by sending the endpoint a confirmation message.
For more information see: [here](http://docs.aws.amazon.com/sns/latest/api/API_Subscribe.html)

 Parameter 	           |       Type     | Description
---------------------- | -------------- | -----------
**params**             | table          | Table of parameters (See API Reference)
**cb**                 | function       | Callback function that takes one parameter (a response table)

where `params` includes

Parameter	             | Type    | Required | Default | Description             
------------------------ | ------- | -------- | ------- | -------------------
Endpoint				 | String  | No 	  | null    | The endpoint that you want to receive notifications. Endpoints vary by protocol:
Protocol				 | String  | Yes	  | N/A     | The protocol you want to use. Supported protocols include: http, https, email, email-json, sms, sqs, application and lambda
TopicArn				 | String  | Yes 	  | N/A     | The topic you want to publish to



#### Example

```squirrel
subscribeParams <- {
    "Protocol": "https",
    "TopicArn": "YOUR_TOPIC_ARN_HERE",
    "Endpoint": http.agenturl()
}

sns.Subscribe(subscribeParams, function (res) {
    server.log("Subscribe Response: " + http.jsonencode(res));
});
```



### Unsubscribe(params, cb)
Deletes a subscription.
For more information see: [here](http://docs.aws.amazon.com/sns/latest/api/API_Unsubscribe.html)

 Parameter 	           |       Type     | Description
---------------------- | -------------- | -----------
**params**             | table          | Table of parameters (See API Reference)
**cb**                 | function       | Callback function that takes one parameter (a response table)


where `params` includes

Parameter                | Type    | Required | Description             
------------------------ | ------- | -------- | --------------------------
SubscriptionArn			 | String  | Yes 	  | The ARN of the subscription to be deleted


#### Example
See ConfirmSubscription [example](#ida) as to how to get a value for SubscriptionArn

```squirrel
local params = {
    "SubscriptionArn": YOUR_SUBSCRIPTION_ARN

    sns.Unsubscribe(params, function(res) {

        server.log("Unsubscribe Response: " + http.jsonencode(res));
    })
}
```



#### Response Table
The format of the response table general to all functions

Parameter		      |       Type     | Description
--------------------- | -------------- | -----------
body				  | String         | SNS response in a XML data structure which is received as a string.
statuscode			  | Integer		   | http status code
headers				  | Table		   | see headers

where `headers` includes

Parameter		      |       Type     | Description
--------------------- | -------------- | -----------
x-amzn-requestid	  | String		   | Amazon request id
content-type		  | String		   | Content type e.g text/XML
date 				  | String		   | The date and time at which response was sent
content-length		  | String		   | the length of the content



# License

The AWSSNS library is licensed under the [MIT License](LICENSE).
