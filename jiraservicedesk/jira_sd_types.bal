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
documentation{Stores the details about Jira SD API compatibility
    F{{api_version}} API resource url
    F{{api_doc_url}} Link to doc for Jira SD API version
}
public type JiraServiceDeskAPI record {
    string api_version;
    string api_doc_url;
    !...
};

documentation{Represents a summary of a jira service desk project.
    F{{resource_path}} API resource url
    F{{sd_id}} service desk Id
    F{{project_id}} project Id
    F{{key}} project key
    F{{name}} project name
}
public type JiraServiceDesk record {
    string resource_path;
    string sd_id;
    string project_id;
    string key;
    string name;
    !...
};

documentation{Represents a jira service desk request type.
    F{{id}} request type id
    F{{name}} name of the request type
    F{{description}} description of the request type
    F{{helpText}} help associated with this request type
}
public type JiraSDRequestType record {
    string id;
    string name;
    string description;
    string helpText;
    !...
};

documentation{Represents the fields for a request type. 
A request type defines the fields required to create 
a customer request.

    F{{field_id}} id of the field
    F{{name}} name of the request type field
    F{{required}} true or false. Is this field required?
    F{{validValues}} any valid values
    F{{field_type}} type of field
}
public type JiraSDRequestTypeField record {
    string field_id;
    string name;
    string description;
    string required;
    RequestTypeFieldValue[] validValues = [];
    string field_type;
};

documentation{Represents the values for a request type.

    F{{value}} value of the field
    F{{label}} lable of the field
}
public type RequestTypeFieldValue record {
    string value;
    string label;
};

documentation{Represents the values for a customer request. It's left an open
record so you can add whatever fields are needed for the creation
of your request in Jira SD. This will vary depending on what request
type is used.

    F{{summary}} summary of the Jira Service Desk issue
}
public type JiraSDCustomerRequest record {
    string summary;
};

documentation{Represents the values from Jira SD when a customer 
request has been created. A customer request in Jira Service Desk (SD)
is the same as an Issue in Jira but in Jira SD its create via the
settings on the customer portal. 

    F{{sd_id}} service desk id this issue is in
    F{{requestTypeId}} id of the request type of this issue
    F{{createdDate}} date stamp of when it was created
    F{{currentStatus}} status of the request
    F{{issueId}} id of the issue in Jira SD
    F{{issueKey}} the key of the issue in Jira SD. ie XXX-123
    F{{reporterKey}}
    F{{reporterName}}
}
public type JiraSDCustomerRequestCreated record {
    string sd_id;
    string requestTypeId;
    string createdDate;
    string currentStatus;
    string issueId;
    string issueKey;
    string reporterKey;
    string reporterName;
};

documentation{Represent Jira Connector based errors.
    F{{^"type"}} type of the error (HTTP error,server error etc.)
    F{{message}} error message
    F{{jiraServerErrorLog}} error log returned by the jira server, for "server error" type
    F{{cause}} cause for the error
}
public type JiraConnectorError record {
    string message;
    error? cause;
    string ^"type";
    json jiraServerErrorLog;
};






