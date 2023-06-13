# Start of Job File
*** Settings ***

Library     CXTA
Resource    cxta.robot
Library     genie.libs.robot.GenieRobot
Library     genie.libs.robot.GenieRobotApis

Library     Collections

Suite Setup         Run Keywords
...                 load testbed        #load testbed file

Suite Teardown      Run Keywords
...                 disconnect from all devices   #disconnect from all devices

*** Test Cases ***

1. CONNECT TO DEVICE UNDER TEST (REST)
    [Documentation]  Connect to device(s) under test via NX-API REST connection.

    ${status}=  Run Keyword And Ignore Error  connect to device "${DEVICE}" via "rest"
    IF  '${status[0]}' == 'FAIL'
        Fail  ++UNSUCCESSFUL++ ${DEVICE} not connected
    ELSE
        Set Test Message  ++SUCCESSFUL++ ${DEVICE} connected \n  append=True
    END

2. VERIFY THE GIVEN INTERFACE STATE IS UP FOR THE DUT
    [Documentation]  Verify given interfaces are in expected state via NX-API.

    ${output}=   nxapi method nxapi cli  device=${DEVICE}  action=send  commands=show interface brief  message_format=json_rpc  command_type=cli  alias=rest
    ${interfaces_dict}=  Set Variable  ${output['result']['body']['TABLE_interface']}
    ${interfaces_list}=    dq query    data=${interfaces_dict}   filters=get_values('interface')
    FOR  ${expected_interface}  IN  @{EXPECTED_INTERFACES}
        IF  "${expected_interface}" in @{interfaces_list}
            ${interface_list_idx}=  Get Index From List  ${interfaces_list}  ${expected_interface}
            ${state}=   Set Variable  ${output['result']['body']['TABLE_interface']['ROW_interface'][${interface_list_idx}]['state']}
            ${status}=  Run Keyword and Return Status  Should Be Equal As Strings  ${EXPECTED_STATE}  ${state}
            IF  ${status}
                Set Test Message  ++SUCCESSFUL++ ${DEVICE} has interface ${expected_interface} in the expected ${EXPECTED_STATE} state\n  append=True
            ELSE
                Fail  ++UNSUCCESSFUL++ Expected interface state was ${EXPECTED_STATE}, but ${DEVICE} has interface ${expected_interface} in the ${state} state
            END
        END
    END
