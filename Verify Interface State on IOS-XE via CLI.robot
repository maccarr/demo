# Start of Job File
*** Settings ***
Library  CXTA
Resource  cxta.robot

Library  BuiltIn
Library  Collections

Suite Setup         Run Keywords
...                 load testbed

Suite Teardown      Run Keywords
...                 Disconnect From All Devices

*** Test Cases ***
1. CONNECT TO DEVICES
    @{DEVICES}=  Get Dictionary Keys  ${DEVICES_DATA}
    Set Suite Variable  @{DEVICES}
    FOR  ${DEVICE}  IN  @{DEVICES}
    ${status}=  Run Keyword And Ignore Error  connect to device "${DEVICE}"
    IF  '${status[0]}' == 'FAIL'
        Fail  ++UNSUCCESSFUL++ ${DEVICE} not connected
    ELSE
        Set Test Message  ++SUCCESSFUL++ ${DEVICE} connected \n  append=True
    END
    END

2. VERIFY INTERFACE STATE
    FOR  ${DEVICE}  IN  @{DEVICES}
        ${output}=  parse "show ip interface brief" on device "${DEVICE}"
        @{expected_interfaces}=  Set Variable  ${DEVICES_DATA['${DEVICE}']['INTERFACES']}
        Log  ${expected_interfaces}
        @{interfaces_list}=  Get Dictionary Keys  ${output['interface']}
        Log  ${interfaces_list}
        FOR  ${expected_interface}  IN  @{expected_interfaces}
            IF  "${expected_interface}" in @{interfaces_list}
                ${int_status}=  Get From Dictionary  ${output['interface']['${expected_interface}']}  status
                ${int_protocol}=  Get From Dictionary  ${output['interface']['${expected_interface}']}  protocol
                ${status_check}=  Run Keyword and Return Status  Should Be Equal As Strings  ${EXPECTED_STATUS}  ${int_status}
                ${protocol_check}=  Run Keyword and Return Status  Should Be Equal As Strings  ${EXPECTED_STATUS}  ${int_protocol}
                IF  ${status_check} and ${protocol_check}
                    Set Test Message  ++SUCCESSFUL++ ${DEVICE} interface ${expected_interface} state is ${int_status}\n  append=True
                ELSE
                    Fail  ++UNSUCCESSFUL++ ${DEVICE} interface ${expected_interface} state is ${int_status}
                END
            END
        END
    END
