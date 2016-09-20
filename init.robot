*** Settings ***
Documentation     Pruebas de API Wunderlist
# Library           Library.py
Library           Collections
Library           RequestsLibrary

*** Variables ***
${API_URL}        http://a.wunderlist.com
${CLIENT ID}      59faafeee266cc5fac01
${CLIENT SECRET}  d8a8da5713d2f1be0d77eb68f4fc10dfa2e09f05c1801dfb797020f4b30b
&{AUTH_HEADERS}   X-Access-Token=${CLIENT SECRET}  X-Client-ID=${CLIENT ID}  Content-Type=application/json
# Wunderlist URLs
${API_USER_URL}   /api/v1/user
${API_TASKS_URL}   /api/v1/tasks
${API_LISTS_URL}   /api/v1/lists

# Ocupar 4 espacios siempre
# Hay ejemplos aqui https://github.com/bulkan/robotframework-requests/blob/master/tests/testcase.txt

*** Test Cases ***
Get Current User Info
    Create Wunderlist Session
    ${resp}=    Get Request    wunderlist    ${API_USER_URL}
    ${jsondata}=    To Json    ${resp.content}
    Log    ${jsondata}
    Should Be Equal As Strings    ${resp.status_code}    200
    Dictionary Should Contain Key    ${jsondata}    id
    Dictionary Should Contain Key    ${jsondata}    name
    Dictionary Should Contain Key    ${jsondata}    email
    Dictionary Should Contain Key    ${jsondata}    type

Get User Lists
    Create Wunderlist Session
    ${resp}=    Get Request    wunderlist    ${API_LISTS_URL}
    Should Be Equal As Strings    ${resp.status_code}    200

Post New Task
  Create Wunderlist Session
  ${id_task}=    Get Any User List
  &{params}=    Create Dictionary    list_id=${id_task}    title=Testing Task
  ${resp}=    Post Request    wunderlist    ${API_TASKS_URL}    data=${params}
  Should Be Equal As Strings    ${resp.status_code}    201

*** Keywords ***
Create Wunderlist Session
    Create Session    wunderlist    ${API_URL}    headers=&{AUTH_HEADERS}

Get Any User List
    Create Wunderlist Session
    ${resp}=    Get Request    wunderlist    ${API_LISTS_URL}
    ${jsondata}=    To Json    ${resp.content}
    ${result}=    Get From List    ${jsondata}    0
    ${id}=    Get From Dictionary    ${result}    id
    [Return]    ${id}
