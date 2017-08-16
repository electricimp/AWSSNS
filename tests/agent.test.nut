// MIT License
//
// Copyright 2017 Electric Imp
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

// Please enter your AWS keys, region and SNS Topic ARN
const AWS_SNS_TEST_REGION = "YOUR_REGION_HERE"
const AWS_SNS_ACCESS_KEY_ID = "YOUR_AWS_ACCESS_KEY_HERE";
const AWS_SNS_SECRET_ACCESS_KEY = "YOUR_AWS_SECRET_ACCESS_KEY_HERE";
const AWS_SNS_TOPIC_ARN = "YOUR_TOPIC_ARN_HERE";

// HTTP status codes
const AWS_TEST_HTTP_RESPONSE_SUCCESS = 200;
const AWS_TEST_HTTP_RESPONSE_FORBIDDEN = 403;
const AWS_TEST_HTTP_RESPONSE_NOT_FOUND = 404;
const AWS_TEST_HTTP_RESPONSE_BAD_REQUEST = 400;

// Invalid data used to fail tests
const AWS_SNS_INVALID_TOPIC_ARN = "arn:adr:spc:us-middle-2:371007585114:derder";
const AWS_SNS_INVALID_SUBSCRIPTION_ARN = "AABBCCDDEEFFGG";

// identifiers in the string of xml
const AWS_SNS_SUBSCRIPTION_ARN_START = "<SubscriptionArn>";
const AWS_SNS_SUBSCRIPTION_ARN_FINISH = "</SubscriptionArn>";

// parameters
const AWS_SNS_PROTOCOL_HTTPS = "https";
const AWS_SNS_MESSAGE = "Hello World";

class AgentTestCase extends ImpTestCase {

    _sns = null;
    _subscriptionArn = null;
    _endpoint = null;

    // setUp initialises the class, subscribes to a topic and confirms that subscription
    function setUp() {

        local subscribeParams = {
            "Protocol": AWS_SNS_PROTOCOL_HTTPS,
            "TopicArn": AWS_SNS_TOPIC_ARN,
            "Endpoint": http.agenturl()
        }
        local firstInstanceConfirmation = true; // only want to perform the assertions once
        // finds the subscription ID,
        local subscriptionFinder = function(messageBody) {

            local start = messageBody.find(AWS_SNS_SUBSCRIPTION_ARN_START);
            local finish = messageBody.find(AWS_SNS_SUBSCRIPTION_ARN_FINISH);
            local subscription = messageBody.slice((start + 17), (finish));
            return subscription;
        }

        _sns = AWSSNS(AWS_SNS_TEST_REGION, AWS_SNS_ACCESS_KEY_ID, AWS_SNS_SECRET_ACCESS_KEY);
        _endpoint = http.agenturl();

        return Promise(function(resolve, reject) {

            // initialise an asynchronous function to receive the token necessary for a confirmation of a subscription
            http.onrequest(function(request, response) {

                response.send(200, "OK");

                try {
                    // Handle an SNS SubscriptionConfirmation request
                    local requestBody = http.jsondecode(request.body);
                    if ("Type" in requestBody && requestBody.Type == "SubscriptionConfirmation") {
                        local confirmParams = {
                            "Token": requestBody.Token,
                            "TopicArn": requestBody.TopicArn
                        }
                        _sns.action(AWSSNS_ACTION_CONFIRM_SUBSCRIPTION, confirmParams, function(res) {

                            try {
                                if (firstInstanceConfirmation == true) {
                                    _subscriptionArn = subscriptionFinder(res.body);
                                    firstInstanceConfirmation = false;
                                    return resolve();
                                }
                            } catch (e) {
                                reject(e);
                            }
                        }.bindenv(this));
                    }
                } catch (e) {
                    reject(e);
                }

            }.bindenv(this));

            // fresh subscribe to ensure timely http message sent to the agent
            _sns.action(AWSSNS_ACTION_SUBSCRIBE, subscribeParams, function(res) {});
        }.bindenv(this));
    }

    // test the subscribe function
    // checks that it receives a successful http response
    // also check that the subscription arn has not been assigned yet
    function testSubscribe() {

        local subscribeParams = {
            "Protocol": AWS_SNS_PROTOCOL_HTTPS,
            "TopicArn": AWS_SNS_TOPIC_ARN,
            "Endpoint": http.agenturl()
        }

        // finds the subscription ID,
        local subscriptionFinder = function(messageBody) {
            local start = messageBody.find(AWS_SNS_SUBSCRIPTION_ARN_START);
            local finish = messageBody.find(AWS_SNS_SUBSCRIPTION_ARN_FINISH);
            local subscription = messageBody.slice((start + 17), (finish));
            return subscription;
        }

        return Promise(function(resolve, reject) {

            _sns.action(AWSSNS_ACTION_SUBSCRIBE, subscribeParams, function(res) {

                try {
                    this.assertTrue(subscriptionFinder(res.body) == "pending confirmation", "actual status " + subscriptionFinder(res.body));
                    this.assertTrue(res.statuscode == AWS_TEST_HTTP_RESPONSE_SUCCESS, "Actual response " + res.statuscode);
                    resolve();
                } catch (e) {
                    reject(e);
                }
            }.bindenv(this));
        }.bindenv(this));
    }

    // test the confirming of a subscription
    // checks that it no longer pending a subscription
    // checks for a successful http response
    function testConfirmSubscription() {

        local firstInstanceConfirmation = true; // only want to perform the assertions once

        // finds the subscription ID,
        local subscriptionFinder = function(messageBody) {

            local start = messageBody.find(AWS_SNS_SUBSCRIPTION_ARN_START);
            local finish = messageBody.find(AWS_SNS_SUBSCRIPTION_ARN_FINISH);
            local subscription = messageBody.slice((start + 17), (finish));
            return subscription;
        }

        local subscribeParams = {
            "Protocol": AWS_SNS_PROTOCOL_HTTPS,
            "TopicArn": AWS_SNS_TOPIC_ARN,
            "Endpoint": http.agenturl()
        }

        return Promise(function(resolve, reject) {


            // initialise an asynchronous function to receive the token necessary for a confirmation of a subscription
            http.onrequest(function(request, response) {

                response.send(200, "OK");

                try {
                    // Handle an SES SubscriptionConfirmation request
                    local requestBody = http.jsondecode(request.body);
                    if ("Type" in requestBody && requestBody.Type == "SubscriptionConfirmation") {
                        local confirmParams = {
                            "Token": requestBody.Token,
                            "TopicArn": requestBody.TopicArn
                        }
                        _sns.action(AWSSNS_ACTION_CONFIRM_SUBSCRIPTION, confirmParams, function(res) {

                            try {
                                if (firstInstanceConfirmation == true) {
                                    // _subscriptionArn = subscriptionFinder(res.body);
                                    this.assertTrue(subscriptionFinder(res.body) != "pending confirmation", "actual status " + subscriptionFinder(res.body));
                                    this.assertTrue(res.statuscode == AWS_TEST_HTTP_RESPONSE_SUCCESS, "Actual response " + res.statuscode);
                                    firstInstanceConfirmation = false;
                                    return resolve();
                                }
                            } catch (e) {
                                reject(e);
                            }
                        }.bindenv(this));
                    }
                } catch (e) {
                    reject(e);
                }

            }.bindenv(this));

            // fresh subscribe to ensure timely http message sent to the agent
            _sns.action(AWSSNS_ACTION_SUBSCRIBE, subscribeParams, function(res) {});
        }.bindenv(this));
    }

    // uses the subscription initialised in setup
    // test the list of subscriptions, checking against the status code
    // also checking if the subscription we put in previously is retrievable
    function testListSubscriptions() {

        // find the endpoint in the response that corresponds to ARN
        local endpointFinder = function(messageBody, endpoint) {
            local start = messageBody.find(endpoint);
            if (start == null) {
                return null;
            }
            else {
                start = start + endpoint.len();
                return start;
            }

        }

        // finds the SubscriptionArn corresponding to the specified endpoint
        local subscriptionFinder = function(messageBody, startIndex) {

            local start = messageBody.find(AWS_SNS_SUBSCRIPTION_ARN_START, startIndex);
            local finish = messageBody.find(AWS_SNS_SUBSCRIPTION_ARN_FINISH, startIndex);
            local subscription = messageBody.slice((start + 17), (finish));
            return subscription;
        }

        return Promise(function(resolve, reject) {

            imp.wakeup(5, function() {
                _sns.action(AWSSNS_ACTION_LIST_SUBSCRIPTIONS, {}, function(res) {

                    if(endpointFinder(res.body, _endpoint) == null) {
                        imp.wakeup(5, function() {

                            _sns.action(AWSSNS_ACTION_LIST_SUBSCRIPTIONS, {}, function(res) {

                                try {
                                    this.assertTrue(res.statuscode == AWS_TEST_HTTP_RESPONSE_SUCCESS, "Actual response " + res.statuscode);
                                    resolve();
                                } catch (e) {
                                    reject(e);
                                }

                            }.bindenv(this));
                        }.bindenv(this))

                    }
                    else {
                        try {
                            this.assertTrue(_subscriptionArn == subscriptionFinder(res.body, endpointFinder(res.body, _endpoint)), "desired Arn " + _subscriptionArn + " Actual Arn " + subscriptionFinder(res.body, endpointFinder(res.body, _endpoint)));
                            this.assertTrue(res.statuscode == AWS_TEST_HTTP_RESPONSE_SUCCESS, "Actual response " + res.statuscode);
                            resolve();
                        } catch (e) {
                            reject(e);
                        }
                    }

                }.bindenv(this));

            }.bindenv(this));

        }.bindenv(this));

    }

    // uses the subscription initialised in setup
    // test the list of subscriptions for a specific topic, checking against the status code
    // also checking if the subscription we put in the topic is retrievable
    function testListSubscriptionsTopic() {

        local Params = {
            "TopicArn": AWS_SNS_TOPIC_ARN
        }

        local firstInstanceConfirmation = true; // only want to perform the assertions once

        local subscribeParams = {
            "Protocol": AWS_SNS_PROTOCOL_HTTPS,
            "TopicArn": AWS_SNS_TOPIC_ARN,
            "Endpoint": http.agenturl()
        }

        // find the endpoint in the response that corresponds to ARN
        local endpointFinder = function(messageBody, endpoint) {

            local start = messageBody.find(endpoint);
            start = start + endpoint.len();
            return start;
        }

        // finds the SubscriptionArn corresponding to the specified endpoint
        local subscriptionFinder = function(messageBody, startIndex) {

            local start = messageBody.find(AWS_SNS_SUBSCRIPTION_ARN_START, startIndex);
            local finish = messageBody.find(AWS_SNS_SUBSCRIPTION_ARN_FINISH, startIndex);
            local subscription = messageBody.slice((start + 17), (finish));
            return subscription;
        }

        return Promise(function(resolve, reject) {

            _sns.action(AWSSNS_ACTION_LIST_SUBSCRIPTIONS_BY_TOPIC, Params, function(res) {

                try {
                    this.assertTrue(_subscriptionArn == subscriptionFinder(res.body, endpointFinder(res.body, _endpoint)), "Actual Arn " + subscriptionFinder(res.body, endpointFinder(res.body, _endpoint)));
                    this.assertTrue(res.statuscode == AWS_TEST_HTTP_RESPONSE_SUCCESS, "Actual response " + res.statuscode);
                    resolve();
                } catch (e) {
                    reject(e);
                }
            }.bindenv(this));

        }.bindenv(this));


    }

    // test the list of Topics, checking against the status code
    // also checking if the Topic we are subscribing to is is retrievable
    function testListTopics() {

        return Promise(function(resolve, reject) {

            _sns.action(AWSSNS_ACTION_LIST_TOPICS, {}, function(res) {

                try {
                    this.assertTrue(res.body.find(AWS_SNS_TOPIC_ARN) != null, "TopicArn not found");
                    this.assertTrue(res.statuscode == AWS_TEST_HTTP_RESPONSE_SUCCESS, "Actual response " + res.statuscode);
                    resolve();
                } catch (e) {
                    reject(e);
                }

            }.bindenv(this));
        }.bindenv(this));
    }

    // tests that the publish function is sent correctly, checks against the statuscode received
    function testPublish() {

        // required params to publish
        local params = {
            "Message": AWS_SNS_MESSAGE,
            "TopicArn": AWS_SNS_TOPIC_ARN,
        }

        return Promise(function(resolve, reject) {

            _sns.action(AWSSNS_ACTION_PUBLISH, params, function(res) {

                try {
                    // checks the received status code
                    this.assertTrue(res.statuscode == AWS_TEST_HTTP_RESPONSE_SUCCESS, "Actual response " + res.statuscode);
                    resolve();
                } catch (e) {
                    reject(e);
                }


            }.bindenv(this));
        }.bindenv(this));
    }

    // uses the subscription from setup
    // unsubscribe the subscription from sns check against the statuscode
    // also checking that the subscription is no longer listed
    function testUnsubscribe() {

        local params = {
            "SubscriptionArn": _subscriptionArn
        }

        return Promise(function(resolve, reject) {

            _sns.action(AWSSNS_ACTION_UNSUBSCRIBE, params, function(res) {

                try {
                    this.assertTrue(res.statuscode == AWS_TEST_HTTP_RESPONSE_SUCCESS, "Actual response " + res.statuscode);

                    _sns.action(AWSSNS_ACTION_LIST_SUBSCRIPTIONS, {}, function(res) {

                        this.assertTrue(res.body.find(_subscriptionArn) == null, "Actual index " + res.body.find(_subscriptionArn));
                        resolve();
                    }.bindenv(this));

                } catch (e) {
                    reject(e);
                }
            }.bindenv(this));
        }.bindenv(this));
    }

    // Fail to unsubscribe the subscription from sns check against the statuscode
    // check to ensure that the subscription is still present
    function testFailUnsubscribe() {

        local params = {
            "SubscriptionArn": AWS_SNS_INVALID_SUBSCRIPTION_ARN
        }

        return Promise(function(resolve, reject) {

            _sns.action(AWSSNS_ACTION_UNSUBSCRIBE, params, function(res) {

                try {
                    this.assertTrue(res.statuscode == AWS_TEST_HTTP_RESPONSE_BAD_REQUEST, "Actual response " + res.statuscode);
                    resolve();
                } catch (e) {
                    reject(e);
                }
            }.bindenv(this));
        }.bindenv(this));
    }

    // test obtaining a list of subscriptions for a an invalid topic
    // tests by confirming a http bad request status
    function testFailListSubscriptionTopic() {

        // params with an invalid topic
        local Params = {
            "TopicArn": AWS_SNS_INVALID_TOPIC_ARN
        }

        return Promise(function(resolve, reject) {

            _sns.action(AWSSNS_ACTION_LIST_SUBSCRIPTIONS_BY_TOPIC, Params, function(res) {

                try {
                    this.assertTrue(res.statuscode == AWS_TEST_HTTP_RESPONSE_BAD_REQUEST, "Actual response " + res.statuscode);
                    resolve();
                } catch (e) {
                    reject(e);
                }
            }.bindenv(this));
        }.bindenv(this));

    }

    // test the list of Topics, checking against the status code
    // also checking if the Topic we are subscribing to is is retrievable
    function testListTopics() {

        return Promise(function(resolve, reject) {

            _sns.action(AWSSNS_ACTION_LIST_TOPICS, {}, function(res) {

                try {
                    this.assertTrue(res.body.find(AWS_SNS_TOPIC_ARN) != null, "TopicArn not found");
                    this.assertTrue(res.statuscode == AWS_TEST_HTTP_RESPONSE_SUCCESS, "Actual response " + res.statuscode);
                    resolve();
                } catch (e) {
                    reject(e);
                }

            }.bindenv(this));
        }.bindenv(this));
    }

    // tests that the publish function is sent correctly, checks against the statuscode received
    function testPublish() {

        // required params to publish
        local params = {
            "Message": AWS_SNS_MESSAGE,
            "TopicArn": AWS_SNS_TOPIC_ARN,
        }

        return Promise(function(resolve, reject) {

            _sns.action(AWSSNS_ACTION_PUBLISH, params, function(res) {

                try {
                    // checks the received status code
                    this.assertTrue(res.statuscode == AWS_TEST_HTTP_RESPONSE_SUCCESS, "Actual response " + res.statuscode);
                    resolve();
                } catch (e) {
                    reject(e);
                }


            }.bindenv(this));
        }.bindenv(this));

    }

    // test publishing to a non existent topicArn, should receive a http status code 400
    function testFailPublish() {

        // required params to publish
        local params = {
            "Message": AWS_SNS_MESSAGE,
            "TopicArn": AWS_SNS_INVALID_TOPIC_ARN,
        }

        return Promise(function(resolve, reject) {

            _sns.action(AWSSNS_ACTION_PUBLISH, params, function(res) {

                try {
                    // checks the received status code
                    this.assertTrue(res.statuscode == AWS_TEST_HTTP_RESPONSE_BAD_REQUEST, "Actual response " + res.statuscode);
                    resolve();
                } catch (e) {
                    reject(e);
                }

            }.bindenv(this));
        }.bindenv(this));
    }

    // Invalid number of parameters checks status code for Confirmation
    function testFailSubscribe() {

        local subscribeParams = {
            "Protocol": AWS_SNS_PROTOCOL_HTTPS,
            "Endpoint": http.agenturl()
        }

        return Promise(function(resolve, reject) {

            _sns.action(AWSSNS_ACTION_SUBSCRIBE, subscribeParams, function(res) {

                try {
                    this.assertTrue(res.statuscode == AWS_TEST_HTTP_RESPONSE_BAD_REQUEST, "Actual response " + res.statuscode);
                    resolve();
                } catch (e) {
                    reject(e);
                }

            }.bindenv(this));
        }.bindenv(this));

    }

    // cleanup after
    function tearDown() {

        local params = {
            "SubscriptionArn": _subscriptionArn
        }

        return Promise(function(resolve, reject) {

            _sns.action(AWSSNS_ACTION_UNSUBSCRIBE, params, function(res) {

                resolve();
            }.bindenv(this));
        }.bindenv(this));
    }
}
