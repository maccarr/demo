# Start of Job File
*** Settings ***

Library     CXTA
Resource    cxta.robot
Library     genie.libs.robot.GenieRobot
Library     genie.libs.robot.GenieRobotApis

Suite Setup         Run Keywords
...                 load testbed        #load testbed file

Suite Teardown      Run Keywords
...                 disconnect from all devices   #disconnect from all devices

*** Test Cases ***

1. CONNECT TO DEVICE UNDER TEST (REST)
    [Documentation]  Connect to DUTs uisng rest connection.

    ${status}=  Run Keyword And Ignore Error  connect to device "${DEVICE}" via "rest"
    IF  '${status[0]}' == 'FAIL'
        Fail  ++UNSUCCESSFUL++ ${DEVICE} not connected
    ELSE
        set test message  ++SUCCESSFUL++ ${DEVICE} connected \n  append=True
    END

2. VERIFY ALL CONFIGURED OSPF NEIGHBOR STATES ARE FULL FOR THE GIVEN DUT
    [Documentation]  Verify all ospf neighbors states.

    ${output}=   nxapi method nxapi cli  device=${DEVICE}  action=send  commands=show ip ospf neighbors  message_format=json_rpc  command_type=cli  alias=rest
    FOR  ${neighbor}  IN  ${output}[result][body][TABLE_ctx][ROW_ctx][TABLE_nbr]
        ${state}=   Set Variable  ${neighbor}[ROW_nbr][state]
        ${rid}=   Set Variable  ${neighbor}[ROW_nbr][rid]
        IF  '${state}' == '${EXPECTED_STATE}'
            set test message  ++SUCCESSFUL++ Neighbor ${rid} state is ${state} \n  append=True
        ELSE
            Fail  ++UNSUCCESSFUL++ Neighbor ${rid} state is ${state}
        END

    END
