//
// Copyright (c) 2018, WSO2 Inc. (http://www.wso2.org) All Rights Reserved.
//
// WSO2 Inc. licenses this file to you under the Apache License,
// Version 2.0 (the "License"); you may not use this file except
// in compliance with the License.
// You may obtain a copy of the License at
//
// http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing,
// software distributed under the License is distributed on an
// "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
// KIND, either express or implied.  See the License for the
// specific language governing permissions and limitations
// under the License.
//

import ballerina/http;
import ballerina/config;
import ballerina/mime;

function errorToJiraConnectorError(error source) returns JiraConnectorError {
    JiraConnectorError target = source.message != EMPTY_STRING ? {message:source.message, cause:source.cause} : {};
    return target;
}

function jsonToJiraServiceDesk(json source) returns JiraServiceDesk {

    JiraServiceDesk target = {};

    target.resource_path = source._links.self.toString();
    target.sd_id = source.id.toString();
    target.project_id = source.projectId.toString();
    target.key = source.projectKey.toString();
    target.name = source.projectName.toString();

    return target;
}

function jsonToJiraSDRequestType(json source) returns JiraSDRequestType {

    JiraSDRequestType target = {};

    target.id = source.id.toString();
    target.name = source.name.toString();
    target.description = source.description.toString();
    target.helpText = source.helpText.toString();
    
    return target;
}

function jiraServiceDeskMatch(JiraServiceDesk jsd_a, JiraServiceDesk jsd_b) returns boolean {

    //if (jsd_a.id == jsd_b.id || jsd_a.name == jsd_b.name || jsd_a.project_id == jsd_b.project_id 
    //        || jsd_a.key == jsd_b.key){
    //    return true;
    //}
    if (jsd_a.key == jsd_b.key || jsd_a.name == jsd_b.name){
        return true;
    }
    return false;
}

function jsonToJiraSDRequestTypeField(json source) returns JiraSDRequestTypeField {

    JiraSDRequestTypeField target = {};

    target.field_id = source.fieldId.toString();
    target.name = source.name.toString();
    target.description = source.description.toString();
    target.required = source.required.toString();
    target.field_type = source.jiraSchema["type"].toString();

    target.validValues = jsonToRequestTypeFieldValues(source.validValues);

    return target;
}

function jsonToRequestTypeFieldValues(json values) returns RequestTypeFieldValue[] {

    RequestTypeFieldValue[] valid_values = [];

    foreach (value in values){
        valid_values[lengthof valid_values] = jsonToRequestTypeFieldValue(value);
    }
    return valid_values;
}

function jsonToRequestTypeFieldValue(json rt_field_value) returns RequestTypeFieldValue {

    RequestTypeFieldValue valid_value = {};

    valid_value.value = rt_field_value.value.toString();
    valid_value.label = rt_field_value.label.toString();
    
    return valid_value;
}

function jsonToJiraSDCustomerRequest(json customer_create_response) returns JiraSDCustomerRequestCreated {

    JiraSDCustomerRequestCreated req = {};

    req.sd_id = customer_create_response.serviceDeskId.toString();
    req.requestTypeId = customer_create_response.requestTypeId.toString();
    req.createdDate = customer_create_response.createdDate.epochMillis.toString();
    req.currentStatus = customer_create_response.currentStatus.status.toString();
    req.issueId = customer_create_response.issueId.toString();
    req.issueKey = customer_create_response.issueKey.toString();
    req.reporterKey = customer_create_response.reporter.Key.toString();
    req.reporterName = customer_create_response.reporter.Name.toString();

    return req;
}




