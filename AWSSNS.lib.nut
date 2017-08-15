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


class AWSSNS {

    static VERSION = "1.0.0";
    static SERVICE = "sns";
    static TARGET_PREFIX = "SNS_20100331";

    _awsRequest = null;    // the aws request object

    // 	Parameters:
    //	 region				AWS region
    //   accessKeyId		AWS access key Id
    //   secretAccessKey    AWS secret access key
    constructor(region, accessKeyId, secretAccessKey) {
        if ("AWSRequestV4" in getroottable()) {
            _awsRequest = AWSRequestV4(SERVICE, region, accessKeyId, secretAccessKey);
        } else {
            throw ("This class requires AWSRequestV4 - please make sure it is loaded.");
        }
    }

    //	Verifies an endpoint owner's intent to receive messages by validating
    //   the token sent to the endpoint by an earlier Subscribe action
    //
    // 	Parameters:
    //    params				table of parameters to be sent as part of the request
    //    cb                    callback function to be called when response received
    //							from aws
    function ConfirmSubscription(params, cb) {
        local headers = { "Content-Type": "application/x-www-form-urlencoded" };

        local body = {
            "Action": "ConfirmSubscription",
            "Version": "2010-03-31"
        };

        foreach (k,v in params) {
            body[k] <- v;
        }

        _awsRequest.post("/", headers, http.urlencode(body), cb);
    }

    //	Returns a xml list of the requester's subscriptions as a string in the response table
    //
    // 	Parameters:
    //    params				table of parameters to be sent as part of the request
    //    cb                    callback function to be called when response received
    //							from aws
    function ListSubscriptions(params, cb) {
        local headers = { "Content-Type": "application/x-www-form-urlencoded" };

        local body = {
            "Action": "ListSubscriptions",
            "Version": "2010-03-31"
        };

        foreach (k,v in params) {
            body[k] <- v;
        }

        _awsRequest.post("/", headers, http.urlencode(body), cb);
    }

    //	Returns a xml list of the requester's subscriptions as a string in
    //  the response table
    //
    // 	Parameters:
    //    params				table of parameters to be sent as part of the request
    //    cb                    callback function to be called when response received
    //							from aws
    function ListSubscriptionsByTopic(params, cb) {
        local headers = { "Content-Type": "application/x-www-form-urlencoded" };

        local body = {
            "Action": "ListSubscriptionsByTopic",
            "Version": "2010-03-31"
        };

        foreach (k,v in params) {
            body[k] <- v;
        }

        _awsRequest.post("/", headers, http.urlencode(body), cb);
    }


    //	Returns a xml list of the requester's topics as a string
    //   in the response table.

    //
    // 	Parameters:
    //    params				table of parameters to be sent as part of the request
    //    cb                    callback function to be called when response received
    //							from aws
    function ListTopics(params, cb) {
        local headers = { "Content-Type": "application/x-www-form-urlencoded" };

        local body = {
            "Action": "ListTopics",
            "Version": "2010-03-31"
        };

        foreach (k,v in params) {
            body[k] <- v;
        }

        _awsRequest.post("/", headers, http.urlencode(body), cb);
    }

    //	Sends a message to an Amazon SNS topic or sends a text message
    //   (SMS message) directly to a phone number.
    //
    // 	Parameters:
    //    params				table of parameters to be sent as part of the request
    //    cb                    callback function to be called when response received
    //							from aws
    function Publish(params, cb) {
        local headers = { "Content-Type": "application/x-www-form-urlencoded" };

        local body = {
            "Action": "Publish",
            "Version": "2010-03-31"
        };

        foreach (k,v in params) {
            body[k] <- v;
        }

        _awsRequest.post("/", headers, http.urlencode(body), cb);
    }

    //	Prepares to subscribe an endpoint by sending the endpoint a
    //   confirmation message.
    //
    // 	Parameters:
    //    params				table of parameters to be sent as part of the request
    //    cb                    callback function to be called when response received
    //							from aws
    function Subscribe(params, cb) {
        local headers = { "Content-Type": "application/x-www-form-urlencoded" };

        local body = {
            "Action": "Subscribe",
            "Version": "2010-03-31"
        };

        foreach (k,v in params) {
            body[k] <- v;
        }

        _awsRequest.post("/", headers, http.urlencode(body), cb);
    }

    //	Deletes a subscription
    //
    // 	Parameters:
    //    params				table of parameters to be sent as part of the request
    //    cb                    callback function to be called when response received
    //							from aws
    function Unsubscribe(params, cb) {
        local headers = { "Content-Type": "application/x-www-form-urlencoded" };

        local body = {
            "Action": "Unsubscribe",
            "Version": "2010-03-31"
        };

        foreach (k,v in params) {
            body[k] <- v;
        }

        _awsRequest.post("/", headers, http.urlencode(body), cb);
    }

}
