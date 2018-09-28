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

documentation{ Represents the Jira SD Client Connector Endpoint configuration.
    F{{clientConfig}} Http client endpoint configuration
}
public type JiraSDConfiguration record {
    http:ClientEndpointConfig clientConfig;
};

documentation{ Represents the Jira SD Client Connector Endpoint object.
    F{{jiraConnector}} jira client connector object
}
public type Client object {
    //public JiraSDConfiguration jiraConfig = {};
    public JiraSDConnector jiraConnector = new;
    //public http:ClientEndpointConfig clientConfig;

    documentation{ Jira connector endpoint initialization function.
        P{{userConfig}} Jira connector endpoint configuration
    }
    public function init(JiraSDConfiguration userConfig) {

        userConfig.clientConfig.url += JIRA_SD_REST_API_RESOURCE;
        userConfig.clientConfig.chunking = "NEVER";
        jiraConnector.jiraHttpClient.init(userConfig.clientConfig);
    }

    documentation{Returns the Jira SD connector client.
        R{{JiraSDConnector}} The Jira SD connector client
    }
    public function getCallerActions() returns JiraSDConnector {
        return jiraConnector;
    }
};
