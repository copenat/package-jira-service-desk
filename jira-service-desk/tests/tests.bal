import ballerina/http;
import ballerina/log;
import ballerina/test;
import ballerina/config;
import wso2/jira7;

JiraServiceDesk service_desk_test = {};
JiraSDRequestType[] request_types_test = [];
JiraSDRequestType request_type_test = {};
JiraSDRequestTypeField[] request_type_values_test = [];

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
    return string `{{e.message}} - {{e.jiraServerErrorLog.errors.toString()}}`;
}

@test:BeforeSuite
function connector_init() {
    //Delete and recreate service desk instance TSD
    log:printInfo("Initialising tests");
    _ = jiraConn->deleteProject("TSD");
    jira7:ProjectRequest test_project_req =
    {
        key: "TSD",
        name: "Test Service Desk",
        projectTypeKey: "service_desk",
        projectTemplateKey: "com.atlassian.servicedesk:itil-v2-service-desk-project",
        description: "Service Desk for automated tests",
        lead: config:getAsString("test_username"),
        assigneeType: "PROJECT_LEAD",
        permissionScheme: "10000"
    };
    jira7:Project test_service_desk;

    var output = jiraConn->createProject(test_project_req);
    match output {
        jira7:Project p => test_service_desk = p;
        jira7:JiraConnectorError e => test:assertFail(msg = formatJiraConnError(e));
    }
    log:printInfo("Successfully created Test Service Desk (TSD)");
}

@test:Config
function test_getAllJiraServiceDesks() {
    log:printInfo("ACTION : getAllJiraServiceDesks()");

    var output = jiraSDConn->getServiceDesks();
    match output {
        JiraServiceDesk[] sd_list => service_desk_test = sd_list[0]; 
        JiraConnectorError e => test:assertFail(msg = formatJiraConnError(e));
    }
}

@test:Config
function test_getAllJiraServiceDesksFail() {
    string ret = "";
    log:printInfo("ACTION : getAllJiraServiceDesksFail()");

    var output = jiraSDConnFail->getServiceDesks();
    match output {
        JiraServiceDesk[] => test:assertFail(msg = "This test is supposed to return a failure.");
        JiraConnectorError e => ret = "Success";
    }
}

@test:Config {
    dependsOn: ["test_getAllJiraServiceDesks"]
}
function test_getJiraServiceDesk() {
    log:printInfo("ACTION : getJiraServiceDesk()");

    JiraServiceDesk jsd1 = {
        name: "Test Service Desk"
    };
    var output = jiraSDConn->getServiceDesk(jsd1);
    match output {
        JiraServiceDesk sd => service_desk_test = sd; 
        JiraConnectorError e => test:assertFail(msg = formatJiraConnError(e));
    }

    JiraServiceDesk jsd2 = {
        key: "TSD"
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









