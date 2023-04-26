*** Settings ***

# CXTA
Library  CXTA
Resource  cxta.robot

Suite Setup     Run Keywords
...             load testbed

Suite Teardown      Run Keywords
...                 Disconnect From All Devices

*** Test Cases ***
1. Example Test 1
  [Documentation]  This is an example test
   Should Be True  1==1