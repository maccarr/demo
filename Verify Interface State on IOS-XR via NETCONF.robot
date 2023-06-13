# Start of Job File
*** Settings ***

# CXTA
Library  CXTA
Resource  cxta.robot

# Import keywords from opensource libraries in robot framework here:
# http://robotframework.org/robotframework/#standard-libraries
Library     Collections

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

Verify Device Interface Status via NETCONF Get Operation
    [Documentation]  Verify given interfaces are in expected state via NETCONF.

    ${output}  ${dict}=     netconf get    filter_type=subtree  filter=${RPC_FILTER}  reply_dict=${true}  device=${DEVICE}  alias=nc1
    ${interfaces_dict}=  Set Variable  ${dict['rpc-reply']['data']['interfaces']}
    ${interfaces_list}=    dq query    data=${interfaces_dict}   filters=get_values('name')
    FOR  ${expected_interface}  IN  @{EXPECTED_INTERFACES}
        IF  "${expected_interface}" in @{interfaces_list}
            ${interface_list_idx}=  Get Index From List  ${interfaces_list}  ${expected_interface}
            ${interface_oper_status}=  Set Variable  ${interfaces_dict['interface'][${interface_list_idx}]['state']['oper-status']}
            ${status}=  Run Keyword and Return Status  Should Be Equal As Strings  ${EXPECTED_STATE}  ${interface_oper_status}
            IF  ${status}
                Set Test Message  ++SUCCESSFUL++ ${DEVICE} has interface ${expected_interface} in the expected ${EXPECTED_STATE} state\n  append=True
            ELSE
                Fail  ++UNSUCCESSFUL++ Expected interface state was ${EXPECTED_STATE}, but ${DEVICE} has interface ${expected_interface} in the ${interface_oper_status} state
            END
        END
    END
