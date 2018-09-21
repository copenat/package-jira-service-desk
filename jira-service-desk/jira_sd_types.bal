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


