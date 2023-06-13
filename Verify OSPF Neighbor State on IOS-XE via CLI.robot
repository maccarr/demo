# Start of Job File
*** Settings ***
Library     CXTA
Resource    cxta.robot

Library     Collections

Suite Setup         Run Keywords
...                 load testbed

Suite Teardown      Run Keywords
...                 disconnect from all devices

*** Test Cases ***
1. Connect to Devices
    FOR  ${DEVICE}  IN  @{DEVICES}
      ${status}=  Run Keyword And Ignore Error  connect to device "${DEVICE}"
      IF  '${status[0]}' == 'FAIL'
        Fail  ++UNSUCCESSFUL++ ${DEVICE} not connected
      ELSE
        set test message  ++SUCCESSFUL++ ${DEVICE} connected \n  append=True
      END
    END

2. Verify OSPF Neighbor State
    FOR  ${DEVICE}  IN  @{DEVICES}
    ${output}=  parse "show ip ospf neighbor" on device "${DEVICE}"
    @{interfaces}=  Get Dictionary Keys  ${output['interfaces']}
        FOR  ${interface}  IN  @{interfaces}
            @{neighbors}=  Get Dictionary Keys  ${output['interfaces']['${interface}']['neighbors']}
            FOR  ${neighbor}  IN  @{neighbors}
                ${state}=  Get From Dictionary  ${output['interfaces']['${interface}']['neighbors']['${neighbor}']}  state
                ${status}=  Run Keyword and Return Status  should be true  '${EXPECTED_STATE}' in '${state}'
                IF  '${status}' == 'False'
                    Fail  ++UNSUCCESSFUL++ neighbor ${neighbor} state on ${DEVICE} is not '${EXPECTED_STATE}'
                ELSE
                    set test message  ++SUCCESSFUL++ neighbor ${neighbor} state on ${DEVICE} is '${EXPECTED_STATE}' \n  append=True
                END
            END
        END
    END
