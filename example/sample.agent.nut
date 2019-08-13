// MIT License
//
// Copyright 2017-19 Electric Imp
//
// SPDX-License-Identifier: MIT
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be
// included in all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
// EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
// MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO
// EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES
// OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE,
// ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR
// OTHER DEALINGS IN THE SOFTWARE.

#require "AWSRequestV4.class.nut:1.0.2"
#require "AWSSNS.agent.lib.nut:2.0.0"


// Configure these parameters see example/README.md for details
const AWS_SNS_TEST_REGION = "YOUR_REGION_HERE"
const AWS_SNS_ACCESS_KEY_ID = "YOUR_AWS_ACCESS_KEY_HERE";
const AWS_SNS_SECRET_ACCESS_KEY = "YOUR_AWS_SECRET_ACCESS_KEY_HERE";
const AWS_SNS_TOPIC_ARN = "YOUR_TOPIC_ARN_HERE";

// Initialise the class
sns <- AWSSNS(AWS_SNS_TEST_REGION, AWS_SNS_ACCESS_KEY_ID, AWS_SNS_SECRET_ACCESS_KEY);

// Parameters for specified functions
subscribeParams <- {
    "Protocol": "https",
    "TopicArn": AWS_SNS_TOPIC_ARN,
    "Endpoint": http.agenturl()
};

publishParams <- {
    "TopicArn": AWS_SNS_TOPIC_ARN,
    "Message": "Hello World"
};

// Handle incoming HTTP requests which are sent in response to subscription to confirm said subscription
http.onrequest(function(request, response) {

    try {
        local requestBody = http.jsondecode(request.body);

        // Handle an SES SubscriptionConfirmation request
        if ("Type" in requestBody && requestBody.Type == "SubscriptionConfirmation") {
            server.log("Received HTTP Request: AWS_SNS SubscriptionConfirmation");

            local confirmParams = {
                "Token": requestBody.Token,
                "TopicArn": requestBody.TopicArn
            }

            // Confirm the subscription
            sns.action(AWSSNS_ACTIONS.CONFIRM_SUBSCRIPTION, confirmParams, function(res) {
                server.log("Confirmation Response: " + res.statuscode);

                if (res.statuscode == 200) {
                    // Now that the subscription is established publish a message
                    sns.action(AWSSNS_ACTIONS.PUBLISH, publishParams, function(res) {
                        server.log(" Publish Confirmation XML Response: " + res.body);
                    });
                }
            });
        }

        response.send(200, "OK");
    } catch (exception) {
        server.log("Error handling HTTP request: " + exception);
        response.send(500, "Internal Server Error: " + exception);
    }

});

// Subscribe to a topic
sns.action(AWSSNS_ACTIONS.SUBSCRIBE, subscribeParams, function(res) {
    server.log("Subscribe Response: " + res.statuscode);
});
