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
import ballerina/log;

documentation{Represents Jira SD Client Connector Object}
public type JiraSDConnector object {

    http:Client jiraHttpClient = new;

    public function getJiraServiceDeskAPICompatibility() returns JiraServiceDeskAPI {
        JiraServiceDeskAPI compatibility = {
            api_version: "3.6.2",
            api_doc_url: "https://docs.atlassian.com/jira-servicedesk/REST/3.6.2/#servicedeskapi/"
        }; 
        return compatibility;  
    }

    public function getServiceDesks() returns JiraServiceDesk[]|JiraConnectorError;
    public function getServiceDesk(JiraServiceDesk jsd) 
        returns JiraServiceDesk|JiraConnectorError;
    public function getRequestTypes(JiraServiceDesk jsd) 
        returns JiraSDRequestType[]|JiraConnectorError;
    public function getRequestType(JiraServiceDesk jsd, string requestTypeName) 
        returns JiraSDRequestType|JiraConnectorError;
    public function getRequestTypeFields(JiraServiceDesk jsd, JiraSDRequestType requestType) 
        returns JiraSDRequestTypeField[]|JiraConnectorError;
    public function createCustomerRequest(
        JiraServiceDesk jsd, JiraSDRequestType requestType, JiraSDCustomerRequest request) 
        returns JiraSDCustomerRequestCreated|JiraConnectorError;

};

documentation{Returns an array of all jira service desk projects which are visible for the 
currently logged in user who has BROWSE, ADMINISTER or PROJECT_ADMIN project permission.
    R{{JiraServiceDesk}} Array of 'JiraServiceDesk' objects
    R{{JiraConnectorError}} 'JiraConnectorError' record presenting an error
}
function JiraSDConnector::getServiceDesks() returns JiraServiceDesk[]|JiraConnectorError {

    endpoint http:Client jiraHttpClientEP = self.jiraHttpClient;
    JiraServiceDesk[] serviceDesks = [];

    var httpResponseOut = jiraHttpClientEP->get("/servicedesk");
    //Evaluate http response for connection and server errors
    var jsonResponseOut = getValidatedResponse(httpResponseOut);
    match jsonResponseOut {
        JiraConnectorError e => return e;

        json jsonResponse => {
            if (jsonResponse.values == null) {
                error err = { message: "Error: server response doesn't contain any projects." };
                return errorToJiraConnectorError(err);
            }
            foreach (jsonSD in jsonResponse.values) {
                serviceDesks[lengthof serviceDesks] = jsonToJiraServiceDesk(jsonSD);
                log:printDebug(jsonSD.toString());
            }
            return serviceDesks;
        }
    }
}

documentation{Returns an array of all jira service desk projects which are visible for the 
currently logged in user who has BROWSE, ADMINISTER or PROJECT_ADMIN project permission.
    P{{jsd}} Record describing the Jira SD project
    R{{JiraServiceDesk}} 'JiraServiceDesk' record fully populated
    R{{JiraConnectorError}} 'JiraConnectorError' record presenting an error
}
function JiraSDConnector::getServiceDesk(JiraServiceDesk jsd) 
            returns JiraServiceDesk|JiraConnectorError {

    endpoint http:Client jiraHttpClientEP = self.jiraHttpClient;
    JiraServiceDesk serviceDesk = {};

    var httpResponseOut = jiraHttpClientEP->get("/servicedesk");
    //Evaluate http response for connection and server errors
    var jsonResponseOut = getValidatedResponse(httpResponseOut);
    match jsonResponseOut {
        JiraConnectorError e => return e;

        json jsonResponse => {
            if (jsonResponse.values == null) {
                error err = { message: "Error: server response doesn't contain any projects." };
                return errorToJiraConnectorError(err);
            }
            log:printDebug("Looking for SD : " + jsd.name);
            foreach (jsonSD in jsonResponse.values) {
                JiraServiceDesk t_jsd = jsonToJiraServiceDesk(jsonSD);
                if (jiraServiceDeskMatch(jsd, t_jsd)){
                    serviceDesk = t_jsd;
                    log:printDebug(jsonSD.toString());
                    return serviceDesk;
                }
            }
            error err = { message: "Error: Unable to find Jira Service Desk" };
            return errorToJiraConnectorError(err); 
        }
    }
}

documentation{Returns an array of all request types for a jira service desk project 
    R{{JiraSDRequestType}} Array of 'JiraSDRequestType' objects
    R{{JiraConnectorError}} 'JiraConnectorError' record presenting an error
}
function JiraSDConnector::getRequestTypes(JiraServiceDesk jsd) 
        returns JiraSDRequestType[]|JiraConnectorError {

    endpoint http:Client jiraHttpClientEP = self.jiraHttpClient;
    JiraSDRequestType[] requestTypes = [];

    var httpResponseOut = jiraHttpClientEP->get("/servicedesk/" + jsd.sd_id + "/requesttype");
    //Evaluate http response for connection and server errors
    var jsonResponseOut = getValidatedResponse(httpResponseOut);
    match jsonResponseOut {
        JiraConnectorError e => return e;
        json jsonResponse => {
            if (jsonResponse.values == null) {
                error err = { message: "Error: Jira Service Desk project doesnt contain "+
                                        "any reuqest types." };
                return errorToJiraConnectorError(err);
            }
            foreach (jsonSDRT in jsonResponse.values) {
                requestTypes[lengthof requestTypes] = jsonToJiraSDRequestType(jsonSDRT);
                log:printDebug(jsonSDRT.toString());
            }
            return requestTypes;
        }
    }
}

documentation{Returns request type for a jira service desk project 
    R{{JiraSDRequestType}} 'JiraSDRequestType' record presenting the request type
    R{{JiraConnectorError}} 'JiraConnectorError' record presenting an error
}
function JiraSDConnector::getRequestType(JiraServiceDesk jsd, string requestTypeName) 
        returns JiraSDRequestType|JiraConnectorError {

    endpoint http:Client jiraHttpClientEP = self.jiraHttpClient;
    JiraSDRequestType requestType = {};

    var httpResponseOut = jiraHttpClientEP->get("/servicedesk/" + jsd.sd_id + "/requesttype");
    //Evaluate http response for connection and server errors
    var jsonResponseOut = getValidatedResponse(httpResponseOut);
    match jsonResponseOut {
        JiraConnectorError e => return e;
        json jsonResponse => {
            if (jsonResponse.values == null) {
                error err = { message: "Error: Jira Service Desk project doesnt contain " +
                                        "any request types." };
                return errorToJiraConnectorError(err);
            }
            foreach (jsonSDRT in jsonResponse.values) {
                if (<string>jsonSDRT.name == requestTypeName){
                    requestType = jsonToJiraSDRequestType(jsonSDRT);
                    log:printDebug(jsonSDRT.toString());
                    return requestType;
                }
            }
            error err = { message: "Error: Unable to find request type " + requestTypeName +
                                    " in Jira SD " + jsd.name + "(id:" + jsd.sd_id + ")" };
            return errorToJiraConnectorError(err);    
        }
    }
}

documentation{Returns request type for a jira service desk project 
    R{{JiraSDRequestType}} 'JiraSDRequestType' record presenting the request type
    R{{JiraConnectorError}} 'JiraConnectorError' record presenting an error
}
function JiraSDConnector::getRequestTypeFields(JiraServiceDesk jsd, JiraSDRequestType requestType) 
        returns JiraSDRequestTypeField[]|JiraConnectorError {

    endpoint http:Client jiraHttpClientEP = self.jiraHttpClient;
    JiraSDRequestTypeField[] request_type_fields = [];

    var httpResponseOut = jiraHttpClientEP->get(
        "/servicedesk/" + jsd.sd_id + "/requesttype/" + requestType.id + "/field");
    //Evaluate http response for connection and server errors
    var jsonResponseOut = getValidatedResponse(httpResponseOut);
    match jsonResponseOut {
        JiraConnectorError e => return e;
        json jsonResponse => {
            foreach (jsonRTField in jsonResponse.requestTypeFields) {
                request_type_fields[lengthof request_type_fields] = jsonToJiraSDRequestTypeField(jsonRTField);
                log:printDebug(jsonRTField.toString());
            }  
            return request_type_fields;
        }
    }
}

documentation{Creates a customer request in the service desk. The equivalent of manually 
entering data via the customer portal. Returns request type for a jira service desk project 
    R{{JiraSDRequestType}} 'JiraSDRequestType' record presenting the request type
    R{{JiraConnectorError}} 'JiraConnectorError' record presenting an error
}
function JiraSDConnector::createCustomerRequest(
        JiraServiceDesk jsd, JiraSDRequestType requestType, JiraSDCustomerRequest request) 
        returns JiraSDCustomerRequestCreated|JiraConnectorError {

    endpoint http:Client jiraHttpClientEP = self.jiraHttpClient;
    JiraSDCustomerRequestCreated create_response = {};

    http:Request outRequest = new;
    json jsonPayload = { "serviceDeskId": jsd.sd_id, "requestTypeId": requestType.id, 
                         "requestFieldValues": check <json>request };
    log:printDebug("Create payload : " + jsonPayload.toString());
    outRequest.setJsonPayload(jsonPayload);

    var httpResponseOut = jiraHttpClientEP->post("/request", outRequest);
    //Evaluate http response for connection and server errors
    var jsonResponseOut = getValidatedResponse(httpResponseOut);
    match jsonResponseOut {
        JiraConnectorError e => return e;
        json jsonResponse => {
            create_response = jsonToJiraSDCustomerRequest(jsonResponse);
            return create_response;
        }
    }
}

















