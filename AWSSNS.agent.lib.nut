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


/**
 * Enum for SNS actions.
 * @enum {string}
 * @readonly
*/
enum AWSSNS_ACTIONS {
    CONFIRM_SUBSCRIPTION        = "ConfirmSubscription",
    LIST_SUBSCRIPTIONS          = "ListSubscriptions",
    LIST_SUBSCRIPTIONS_BY_TOPIC = "ListSubscriptionsByTopic",
    LIST_TOPICS                 = "ListTopics",
    PUBLISH                     = "Publish",
    SUBSCRIBE                   = "Subscribe",
    UNSUBSCRIBE                 = "Unsubscribe"
}

/**
 * Enum for SNS action response indentifiers.
 * @enum {string}
 * @readonly
*/
enum AWSSNS_RESPONSES {
    SUBSCRIPTION_CONFIRMATION = "SubscriptionConfirmation",
}

/**
 * Squirrel class providing support for AWS' SNS service.
 *
 * Availibility Agent
 * Requires     AWSRequestV4
 * @author      Pavel Petrosenko
 * @license     MIT
 *
 * @class
*/
class AWSSNS {

    static VERSION = "2.0.0";

    _awsRequest = null;

    /**
     * Instantiate the AWSSNS class.
     *
     * @constructor
     *
     * @param {USB.Device} region          - An AWS region.
     * @param {USB.Device} accessKeyId     - An AWS access key ID.
     * @param {USB.Device} secretAccessKey - An AWS secret access key.
     *
     * @returns {instance} The instance.
     */
    constructor(region, accessKeyId, secretAccessKey) {
        if ("AWSRequestV4" in getroottable()) {
            _awsRequest = AWSRequestV4("sns", region, accessKeyId, secretAccessKey);
        } else {
            throw "This class requires AWSRequestV4 - please make sure it is loaded.";
        }
    }

    /**
     * Performs the specified action.
     *
     * @param {string}   action - The name of the action to be performed.
     * @param {table}    params - Parameters to be sent as part of the request.
     * @param {function} cb     - Callback function triggered when response received from AWS.
    */
    function action(action, params, cb) {
        local headers = {"Content-Type": "application/x-www-form-urlencoded"};
        local body = {
            "Action": action,
            "Version": "2010-03-31"
        };
        foreach (k,v in params) {
            body[k] <- v;
        }
        _awsRequest.post("/", headers, http.urlencode(body), cb);
    }
}
