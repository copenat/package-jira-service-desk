import ballerina/http;
import ballerina/log;
import ballerina/test;
import ballerina/config;
import wso2/jira7;

// This Jira Service Desk project needs to be created before running these tests
JiraServiceDesk service_desk_test = {
    name: "Test Service Desk",
    key: "TSD"
};
JiraSDRequestType[] request_types_test = [];
JiraSDRequestType request_type_test = {};
JiraSDRequestTypeField[] request_type_values_test = [];
JiraSDCustomerRequestCreated customer_request_test = {};


endpoint jira7:Client jiraConn {
    clientConfig: {
        url: config:getAsString("test_url"),
        auth: {
            scheme: http:BASIC_AUTH,
            username: config:getAsString("test_username"),
            password: config:getAsString("test_password")
        }
    }
};

endpoint Client jiraSDConn {
    clientConfig: {
        url: config:getAsString("test_url"),
        auth: {
            scheme: http:BASIC_AUTH,
            username: config:getAsString("test_username"),
            password: config:getAsString("test_password")
        }
    }
};

endpoint Client jiraSDConnFail {
    clientConfig: {
        url: "http://blah:10",
        auth: {
            scheme: http:BASIC_AUTH,
            username: "fail",
            password: "fail"
        }
    }
};

function formatJiraConnError(JiraConnectorError e) returns string {
    return string `{{e.message}} - {{e.jiraServerErrorLog.toString()}}`;
}

@test:BeforeSuite
function connector_init() {
    log:printInfo("Initialising tests");
}

@test:Config
function test_getJiraServiceDeskAPICompatibility() {
    string msg = "";
    log:printInfo("ACTION : getJiraServiceDeskAPICompatibility()");

    var output = jiraSDConn->getJiraServiceDeskAPICompatibility();
    match output {
        JiraServiceDeskAPI api_version_details => _ = api_version_details;
        JiraConnectorError e => test:assertFail(msg = formatJiraConnError(e));
    }
}

@test:Config
function test_getAllJiraServiceDesks() {
    string msg = "";
    log:printInfo("ACTION : getAllJiraServiceDesks()");

    var output = jiraSDConn->getServiceDesks();
    match output {
        JiraServiceDesk[] => msg = "Success";
        JiraConnectorError e => test:assertFail(msg = formatJiraConnError(e));
    }
}

@test:Config
function test_getAllJiraServiceDesksFail() {
    string msg = "";
    log:printInfo("ACTION : getAllJiraServiceDesksFail()");

    var output = jiraSDConnFail->getServiceDesks();
    match output {
        JiraServiceDesk[] => test:assertFail(msg = "This test is supposed to return a failure.");
        JiraConnectorError e => msg = "Success";
    }
}

@test:Config {
    dependsOn: ["test_getAllJiraServiceDesks"]
}
function test_getJiraServiceDesk() {
    log:printInfo("ACTION : getJiraServiceDesk()");

    JiraServiceDesk jsd1 = {
        name: service_desk_test.name
    };
    var output = jiraSDConn->getServiceDesk(jsd1);
    match output {
        JiraServiceDesk sd => service_desk_test = sd; 
        JiraConnectorError e => test:assertFail(msg = formatJiraConnError(e));
    }

    JiraServiceDesk jsd2 = {
        key: service_desk_test.key
    };
    output = jiraSDConn->getServiceDesk(jsd2);
    match output {
        JiraServiceDesk sd => service_desk_test = sd; 
        JiraConnectorError e => test:assertFail(msg = formatJiraConnError(e));
    }
}

@test:Config {
    dependsOn: ["test_getAllJiraServiceDesks"]
}
function test_getRequestTypesForJiraSDProject() {
    log:printInfo("ACTION : getRequestTypesForJiraSDProject()");

    var output = jiraSDConn->getRequestTypes(service_desk_test);
    match output {
        JiraSDRequestType[] rt_list => request_types_test = rt_list; 
        JiraConnectorError e => test:assertFail(msg = formatJiraConnError(e));
    }
}

@test:Config {
    dependsOn: ["test_getJiraServiceDesk"]
}
function test_getRequestTypeForJiraSDProject() {
    log:printInfo("ACTION : getRequestTypeForJiraSDProject()");

    var output = jiraSDConn->getRequestType(service_desk_test, "Request new software");
    match output {
        JiraSDRequestType rt => {
            request_type_test = rt;
            json requestType_json = check <json>request_type_test;
            log:printInfo("Successfully found request type : " + requestType_json.toString());
        } 
        JiraConnectorError e => test:assertFail(msg = formatJiraConnError(e));
    }
}

@test:Config {
    dependsOn: ["test_getJiraServiceDesk"]
}
function test_getRequestTypeForJiraSDProjectFail() {
    string ret = "";
    log:printInfo("ACTION : getRequestTypeForJiraSDProjectFail()");

    var output = jiraSDConn->getRequestType(service_desk_test, "DOESNOTEXIST");
    match output {
        JiraSDRequestType => test:assertFail(msg = "This test is supposed to return a failure.");
        JiraConnectorError e => ret = "Success";
    }
}

@test:Config {
    dependsOn: ["test_getRequestTypeForJiraSDProject"]
}
function test_getRequestTypeFieldsForJiraSDProject() {
    log:printInfo("ACTION : getRequestTypeFieldsForJiraSDProject()");

    var output = jiraSDConn->getRequestTypeFields(service_desk_test, request_type_test);
    match output {
        JiraSDRequestTypeField[] field_value_list => {
            request_type_values_test = field_value_list;
            log:printInfo("Successfully found request type fields");
        } 
        JiraConnectorError e => test:assertFail(msg = formatJiraConnError(e));
    }
}

@test:Config {
    dependsOn: ["test_getRequestTypeFieldsForJiraSDProject"]
}
function test_createCustomerRequest() {
    string ret = "";
    log:printInfo("ACTION : createCustomerRequest()");
    JiraSDCustomerRequest customer_request = {
        summary: "Requesting software - testing Jira SD API connector Ballerina"
    };
    var output = jiraSDConn->createCustomerRequest(service_desk_test, request_type_test, customer_request);
    match output {
        JiraSDCustomerRequestCreated => test:assertFail(msg = "This test is supposed to return a failure.");
        JiraConnectorError => ret = "Success";
    }

    customer_request = {
        summary: "Requesting software - testing Jira SD API connector Ballerina",
        description: "this desciption field is mandatory for this request type"
    };
    output = jiraSDConn->createCustomerRequest(service_desk_test, request_type_test, customer_request);
    match output {
        JiraSDCustomerRequestCreated cr => {
            customer_request_test = cr;
            json created_json = check <json>customer_request_test;
            log:printInfo("Successfully created customer request : " + created_json.toString());
        } 
        JiraConnectorError e => test:assertFail(msg = formatJiraConnError(e));
    }
}








