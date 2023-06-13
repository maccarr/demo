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
    FOR  ${DEVICE}  IN  @{DEVICES}
    ${status}=  Run Keyword And Ignore Error  connect to device "${DEVICE}"
        IF  '${status[0]}' == 'FAIL'
            Fail  ++UNSUCCESSFUL++ ${DEVICE} not connected
        ELSE
            set test message  ++SUCCESSFUL++ ${DEVICE} connected \n  append=True
        END
    END

2. VERIFY SOFTWARE VERSION
    FOR  ${DEVICE}  IN  @{DEVICES}
    ${os}=    from testbed devices get "${DEVICE}.os"
      IF    "${os}" == "iosxe" and "8K" in "${DEVICE}"
        select device "${DEVICE}"
        ${VERSION_OUTPUT}=  parse "show version" on device "${DEVICE}"
        ${CFG_VERSION}=  Get From Dictionary  ${VERSION_OUTPUT['version']}  version
        ${status}=  Run Keyword And Return Status  should be true  '${CFG_VERSION}' == '${EXP_XE_8K_VERSION}'
        IF  '${status}' == 'False'
            Fail  ++UNSUCCESSFUL++ Device ${DEVICE} is not running the expected version ${EXP_XE_8K_VERSION}
        ELSE
            set test message  ++SUCCESSFUL++ ${DEVICE} is running the expected version ${CFG_VERSION}\n  append=True
        END
      ELSE IF    "${os}" == "iosxe" and "1K" in "${DEVICE}"
        select device "${DEVICE}"
        ${VERSION_OUTPUT}=  parse "show version" on device "${DEVICE}"
        ${CFG_VERSION}=  Get From Dictionary  ${VERSION_OUTPUT['version']}  version
        ${status}=  Run Keyword And Return Status  should be true  '${CFG_VERSION}' == '${EXP_XE_1K_VERSION}'
        IF  '${status}' == 'False'
            Fail  ++UNSUCCESSFUL++ Device ${DEVICE} is not running the expected version ${EXP_XE_1K_VERSION}
        ELSE
            set test message  ++SUCCESSFUL++ ${DEVICE} is running the expected version ${CFG_VERSION}\n  append=True
        END
      ELSE IF    "${os}" == "iosxr"
        select device "${DEVICE}"
        ${VERSION_OUTPUT}=  parse "show version" on device "${DEVICE}"
        ${CFG_VERSION}=  Get From Dictionary  ${VERSION_OUTPUT}  software_version
        ${status}=  Run Keyword And Return Status  should be true  '${CFG_VERSION}' == '${EXP_XR_VERSION}'
        IF  '${status}' == 'False'
            Fail  ++UNSUCCESSFUL++ Device ${DEVICE} is not running the expected version ${EXP_XR_VERSION}
        ELSE
            set test message  ++SUCCESSFUL++ ${DEVICE} is running the expected version ${CFG_VERSION}\n  append=True
        END
      ELSE IF    "${os}" == "nxos"
        select device "${DEVICE}"
        ${VERSION_OUTPUT}=  parse "show version" on device "${DEVICE}"
        ${CFG_VERSION}=  Get From Dictionary  ${VERSION_OUTPUT['platform']['software']}  system_version
        ${status}=  Run Keyword And Return Status  should be true  '${CFG_VERSION}' == '${EXP_NXOS_VERSION}'
        IF  '${status}' == 'False'
            Fail  ++UNSUCCESSFUL++ Device ${DEVICE} is not running the expected version ${EXP_NXOS_VERSION}
        ELSE
            set test message  ++SUCCESSFUL++ ${DEVICE} is running the expected version ${CFG_VERSION}\n  append=True
        END
      END
    END