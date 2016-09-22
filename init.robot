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
# Librerias RobotFramework http://robotframework.org/robotframework/latest/libraries/BuiltIn.html#Catenate


*** Test Cases ***

#############
### Users ###
#############
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

#############
### Tasks ###
#############
Post New Task
  Create Wunderlist Session
  ${id_task}=    Get Any User List
  &{params}=    Create Dictionary    list_id=${id_task}    title=Testing Task
  ${resp}=    Post Request    wunderlist    ${API_TASKS_URL}    data=${params}
  Should Be Equal As Strings    ${resp.status_code}    201

#############
### List ###
#############

Get User Lists
    Create Wunderlist Session
    ${resp}=    Get Request    wunderlist    ${API_LISTS_URL}
    Should Be Equal As Strings    ${resp.status_code}    200

Create New List
  Create Wunderlist Session
  &{params}=    Create Dictionary    title=New List
  ${resp}=    Post Request    wunderlist    ${API_LISTS_URL}    data=${params}
  Should Be Equal As Strings    ${resp.status_code}    201

Get a specific List
  Create Wunderlist Session
  ${id_list}=    Get Any User List
  ${link}=    Catenate  SEPARATOR=  ${API_LISTS_URL}    /    ${id_list}
  ${resp}=    Get Request    wunderlist    ${link}
  Should Be Equal As Strings    ${resp.status_code}    200

Update a List
  Create Wunderlist Session
  ${id}   ${revision}     Get Helper List
  &{params}=    Create Dictionary    revision=${revision}    title=New Title
  ${link}=    Catenate  SEPARATOR=  ${API_LISTS_URL}    /    ${id}
  ${resp}=    PATCH Request    wunderlist    ${link}    data=${params}
  Should Be Equal As Strings    ${resp.status_code}    200

Destroy a Given List
  Create Wunderlist Session
  ${id}   ${revision}     Get Helper List
  &{params}=    Create Dictionary    revision=${revision}
  ${link}=    Catenate  SEPARATOR=  ${API_LISTS_URL}    /    ${id}
  ${resp}=    DELETE Request    wunderlist    ${link}     params=&{params}
  Should Be Equal As Strings    ${resp.status_code}    204

Destroy all Lists
  Create Wunderlist Session
  ${id}   ${revision}     Get Helper List
  :FOR    ${ELEMENT}    IN    @{ITEMS}
    &{params}=    Create Dictionary    revision=${revision}
    ${link}=    Catenate  SEPARATOR=  ${API_LISTS_URL}    /    ${id}
    ${resp}=    DELETE Request    wunderlist    ${link}     params=&{params}
    Should Be Equal As Strings    ${resp.status_code}    204

*** Keywords ***
Create Wunderlist Session
    Create Session    wunderlist    ${API_URL}    headers=&{AUTH_HEADERS}

Get Any User List
    Create Wunderlist Session
    ${resp}=    Get Request    wunderlist    ${API_LISTS_URL}
    ${jsondata}=    To Json    ${resp.content}
    ${length}=    Get Length      ${jsondata}
    ${number}=    Evaluate    random.sample(range(1, ${length} - 1), 1)    random
    ${number}=    Get From List     ${number}     0
    ${result}=    Get From List    ${jsondata}    ${number}
    ${id}=    Get From Dictionary    ${result}    id
    [Return]    ${id}

Get Helper List
    Create Wunderlist Session
    &{params}=    Create Dictionary    title=Helper List
    ${resp}=    Post Request    wunderlist    ${API_LISTS_URL}    data=${params}
    ${jsondata}=    To Json    ${resp.content}
    ${id}=    Get From Dictionary    ${jsondata}    id
    ${revision}=     Get From Dictionary    ${jsondata}    revision
    [Return]    ${id}   ${revision}
