# Start of Job File
*** Settings ***

# CXTA
Library  CXTA
Resource  cxta.robot

Suite Setup     Run Keywords
...             load testbed

Suite Teardown      Run Keywords
...                 Disconnect From All Devices

*** Test Cases ***
Connect to device via NETCONF
    [Documentation]  Connect to device(s) under test via NETCONF connection.

    set netconf timeout to "180" seconds
    ${status}=  Run Keyword And Ignore Error  connect to device "${DEVICE}" via netconf using alias "nc1"
    IF  '${status[0]}' == 'FAIL'
        Fail  ++UNSUCCESSFUL++ ${DEVICE} not connected
    ELSE
        Set Test Message  ++SUCCESSFUL++ ${DEVICE} connected \n  append=True
    END

Verify Device OSPF Neighbors State via NETCONF Get Operation
    [Documentation]  Verify OSPF neighbors are in expected state via NETCONF.

    ${output}  ${dict}=     netconf get    filter_type=subtree  filter=${RPC_FILTER}  reply_dict=${true}  device=${DEVICE}  alias=nc1
    Log  ${output}
    Log  ${dict}
    ${ospf_neighbor_list}=    Set Variable  ${dict['rpc-reply']['data']['ospf']['processes']['process']['default-vrf']['adjacency-information']['neighbors']['neighbor']}
    FOR  ${ospf_neighbor}  IN  @{ospf_neighbor_list}
        ${status}=  Run Keyword and Return Status  Should Be Equal As Strings  ${EXPECTED_STATE}  ${ospf_neighbor['neighbor-state']}
        IF  ${status}
            Set Test Message  ++SUCCESSFUL++ ${DEVICE} has OSPF neighbors in the expected ${EXPECTED_STATE} state\n  append=True
        ELSE
            ${ospf_neighbor_addr}=  Set Variable  ${ospf_neighbor['neighbor-address']}
            Fail  ++UNSUCCESSFUL++ Expected OSPF neighbor state was ${EXPECTED_STATE}, but ${DEVICE} has OSPF neighbor ${ospf_neighbor_addr} in the ${ospf_neighbor['neighbor-state'] state
        END
    END
