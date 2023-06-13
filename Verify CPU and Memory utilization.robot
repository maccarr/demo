*** Settings ***
# CXTA
Library             CXTA
Resource            cxta.robot

# CX-CATL Keywords
Resource            ${EXECDIR}${/}library${/}keywords${/}iosxr-global.resource
Resource            ${EXECDIR}${/}library${/}system${/}monitoring${/}cpu${/}keywords${/}iosxr-cpu.resource

# Import Robot Framework keywords from open source or custom libraries:
# http://robotframework.org/robotframework/#standard-libraries
Library             Collections

# Load topology/testbed file
Suite Setup         Load Connection File And Connect

# Disconnect sessions from all devices
Suite Teardown      Run Keywords
...                     disconnect from all devices

Metadata            CXTA_Developed_Version    22.22


*** Test Cases ***
1. VERIFY CPU UTILIZATION ON DEVICES
    [Documentation]    Verifies CPU utilization on devices
    IOSXR Verify CPU Utilization On Devices
    ...    devices=${DEVICE_LIST}
    ...    cpu_threshold=${EXP_CPU_THRESHOLD}

2. VERIFY MEMORY UTILIZATION ON DEVICES
    [Documentation]    Verifies memory utilization on devices
    IOSXR Verify Memory Utilization On Devices
    ...    devices=${DEVICE_LIST}
    ...    exp_memory_percentage=${EXP_MEMORY_PERCENTAGE}
