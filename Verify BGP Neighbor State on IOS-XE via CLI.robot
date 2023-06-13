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


1. CONNECT TO DEVICE UNDER TEST (SSH)
    FOR  ${DEVICE}  IN  @{DEVICES}
        ${status}=  Run Keyword And Ignore Error  connect to device "${DEVICE}"
        IF  '${status[0]}' == 'FAIL'
            Fail  ++UNSUCCESSFUL++ ${DEVICE} not connected
        ELSE
            set test message  ++SUCCESSFUL++ ${DEVICE} connected \n  append=True
        END
    END

2. VERIFY ALL CONFIGURED BGP NEIGHBOR STATES ESTABLISHED FOR THE GIVEN DUT
    FOR  ${DEVICE}  IN  @{DEVICES}
    ${output}=  parse "show bgp neighbors" on device "${DEVICE}"
    @{neighbors}=   Set Variable  ${output}[list_of_neighbors]
        FOR  ${neighbor}  IN  @{neighbors}
            ${state}=   Set Variable  ${output}[vrf][default][neighbor][${neighbor}][session_state]
            IF  '${state}' == '${EXPECTED_STATE}'
                set test message  ++SUCCESSFUL++ Neighbor ${neighbor} state is ${state} \n  append=True
            ELSE
                Fail  ++UNSUCCESSFUL++ Neighbor ${neighbor} state is ${state}
            END
        END
    END
