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
    [Documentation]  Connect to uisng REST connection

    ${status}=  Run Keyword And Ignore Error  connect to device "${DEVICE}" via "rest"
    IF  '${status[0]}' == 'FAIL'
        Fail  ++UNSUCCESSFUL++ ${DEVICE} not connected
    ELSE
        set test message  ++SUCCESSFUL++ ${DEVICE} connected \n  append=True
    END

2. VERIFY ALL CONFIGURED BGP NEIGHBOR STATES ESTABLISHED FOR THE GIVEN DUT
    [Documentation]  Verify all BGP neighbor states are as expected

    ${output}=   nxapi method nxapi cli  device=${DEVICE}  action=send  commands=show bgp ipv4 unicast summary  message_format=json_rpc  command_type=cli  alias=rest
    ${neighbors}=  Set Variable   ${output}[result][body][TABLE_vrf][ROW_vrf][TABLE_af][ROW_af][TABLE_saf][ROW_saf][TABLE_neighbor][ROW_neighbor]
    ${is_list}=      Evaluate     isinstance($neighbors, list)
    IF  ${is_list}
        FOR  ${neighbor}  IN  @{neighbors}
            ${state}=   Set Variable  ${neighbor}[state]
            ${neighbor_rtr_id}=   Set Variable  ${neighbor}[neighborid]
        END
    ELSE
        ${state}=   Set Variable  ${neighbors}[state]
        ${neighbor_rtr_id}=   Set Variable  ${neighbors}[neighborid]
    END

    ${status}=  Run Keyword and Return Status  Should Be Equal As Strings  ${EXPECTED_STATE}  ${state}
    IF  ${status}
        Set Test Message  ++SUCCESSFUL++ ${DEVICE} has BGP neighbor ${neighbor_rtr_id} in the expected ${EXPECTED_STATE} state\n  append=True
    ELSE
        Fail  ++UNSUCCESSFUL++ Expected BGP neighbor state ${EXPECTED_STATE}, but ${DEVICE} has BGP neighbor ${neighbor_rtr_id} in the ${state} state
    END
