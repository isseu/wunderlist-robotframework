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
${API_USER_URL}        /api/v1/user
${API_TASKS_URL}       /api/v1/tasks
${API_TASKS_COMMENTS}  /api/v1/task_comments
${API_LISTS_URL}       /api/v1/lists
${API_FOLDERS_URL}     /api/v1/folders
${API_MEMBERSHIPS_URL} /api/v1/memberships

# Ocupar 4 espacios siempre
# Hay ejemplos aqui https://github.com/bulkan/robotframework-requests/blob/master/tests/testcase.txt
# Librerias RobotFramework http://robotframework.org/robotframework/latest/libraries/BuiltIn.html#Catenate

*** Test Cases ***

#############
## Folders ##
#############

Get User Folders
    Create Wunderlist Session
    ${resp}=    Get Request    wunderlist    ${API_FOLDERS_URL}
    Should Be Equal As Strings    ${resp.status_code}    200

Create New Folder
    Create Wunderlist Session
    ${number}=    Evaluate    random.sample(range(1, 2), 1)    random
    &{params}=    Create Dictionary    title=New Folder    list_ids=${number}
    ${resp}=    Post Request    wunderlist    ${API_FOLDERS_URL}    data=${params}
    Should Be Equal As Strings    ${resp.status_code}    201
    ${jsondata}=    To Json    ${resp.content}
    Dictionary Should Contain Key    ${jsondata}    id
    ${id_folder}=    Get From Dictionary    ${jsondata}    id
    # Should exists
    ${resp}=    Get Request    wunderlist    ${API_FOLDERS_URL}/${id_folder}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${jsondata}=    To Json    ${resp.content}
    Dictionary Should Contain Key    ${jsondata}    title
    Dictionary Should Contain Item    ${jsondata}    title    New Folder

#############
### Users ###
#############
Get Current User Info
    Create Wunderlist Session
    ${resp}=    Get Request    wunderlist    ${API_USER_URL}
    ${jsondata}=    To Json    ${resp.content}
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
    ${id_list}   ${revision}     Get Any User List
    &{params}=    Create Dictionary    list_id=${id_list}    title=Testing Task
    ${resp}=    Post Request    wunderlist    ${API_TASKS_URL}    data=${params}
    Should Be Equal As Strings    ${resp.status_code}    201

Get Tasks From List
    Create Wunderlist Session
    ${id_list}   ${revision}     Get Any User List
    &{params}=    Create Dictionary    list_id=${id_list}
    ${resp}=    Get Request    wunderlist    ${API_TASKS_URL}    params=${params}
    Should Be Equal As Strings    ${resp.status_code}    200

Get Completed Tasks From List
    Create Wunderlist Session
    ${id_list}   ${revision}     Get Any User List
    &{params}=    Create Dictionary    list_id=${id_list}    completed=true
    ${resp}=    Get Request    wunderlist    ${API_TASKS_URL}    params=${params}
    Should Be Equal As Strings    ${resp.status_code}    200

Get Specific Task
    Create Wunderlist Session
    ${id_list}   ${revision}     Get Any User List
    &{params}=    Create Dictionary    list_id=${id_list}    completed=true
    ${resp}=    Get Request    wunderlist    ${API_TASKS_URL}    params=${params}
    Should Be Equal As Strings    ${resp.status_code}    200

Update a task
    Create Wunderlist Session
    ${id_list}   ${revision}     Get Any User List
    &{params}=    Create Dictionary    list_id=${id_list}    title=Testing Task
    ${resp}=    Post Request    wunderlist    ${API_TASKS_URL}    data=${params}
    ${result}=    To Json    ${resp.content}
    ${id_task}=    Get From Dictionary    ${result}    id
    ${revision}=     Get From Dictionary    ${result}    revision

    &{params}=    Create Dictionary    revision=${revision}    title=Updating a Task
    ${link}=    Catenate  SEPARATOR=  ${API_TASKS_URL}    /    ${id_task}
    ${resp}=    PATCH Request    wunderlist    ${link}    data=${params}
    Should Be Equal As Strings    ${resp.status_code}    200

Delete a task
    Create Wunderlist Session
    ${id_list}   ${revision}     Get Any User List
    &{params}=    Create Dictionary    list_id=${id_list}    title=Testing Task
    ${resp}=    Post Request    wunderlist    ${API_TASKS_URL}    data=${params}

    ${result}=    To Json    ${resp.content}
    ${id_task}=    Get From Dictionary    ${result}    id
    ${revision}=     Get From Dictionary    ${result}    revision

    &{params}=    Create Dictionary    revision=${revision}
    ${link}=    Catenate  SEPARATOR=  ${API_TASKS_URL}    /    ${id_task}
    ${resp}=    DELETE Request    wunderlist    ${link}     params=&{params}
    Should Be Equal As Strings    ${resp.status_code}    204

#############
###Comments##
#############

Create Comment on task
    Create Wunderlist Session
    ${id_list}   ${revision}     Get Any User List
    &{params}=    Create Dictionary    list_id=${id_list}    title=Creating Comment Task
    ${resp}=    Post Request    wunderlist    ${API_TASKS_URL}    data=${params}
    ${jsondata}=    To Json    ${resp.content}
    ${id_task}=    Get From Dictionary    ${jsondata}    id

    &{params}=    Create Dictionary    task_id=${id_task}    text=First Comment
    ${resp}=    Post Request    wunderlist    ${API_TASKS_COMMENTS}    data=${params}
    Should Be Equal As Strings    ${resp.status_code}    201



#############
### Membership ###
#############

Get User Memberships
    Create Wunderlist Session
    ${resp}=    Get Request    wunderlist    ${API_MEMBERSHIPS_URL}
    Should Be Equal As Strings    ${resp.status_code}    200

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
    ${id_list}   ${revision}     Get Any User List
    ${link}=    Catenate  SEPARATOR=  ${API_LISTS_URL}    /    ${id_list}
    ${resp}=    Get Request    wunderlist    ${link}
    Should Be Equal As Strings    ${resp.status_code}    200

Update a List
    Create Wunderlist Session
    ${id}   ${revision}     Get Any User List
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
    ${revision}=     Get From Dictionary    ${result}    revision
    [Return]    ${id}     ${revision}

Get Any User Membership
    Create Wunderlist Session
    ${resp}=    Get Request    wunderlist    ${API_MEMBERSHIPS_URL}
    ${jsondata}=    To Json    ${resp.content}
    ${length}=    Get Length      ${jsondata}
    ${number}=    Evaluate    random.sample(range(1, ${length} - 1), 1)    random
    ${number}=    Get From List     ${number}     0
    ${result}=    Get From List    ${jsondata}    ${number}
    ${id}=    Get From Dictionary    ${result}    id
    ${revision}=     Get From Dictionary    ${result}    revision
    [Return]    ${id}     ${revision}

Get Helper List
    Create Wunderlist Session
    &{params}=    Create Dictionary    title=Helper List
    ${resp}=    Post Request    wunderlist    ${API_LISTS_URL}    data=${params}
    ${jsondata}=    To Json    ${resp.content}
    ${id}=    Get From Dictionary    ${jsondata}    id
    ${revision}=     Get From Dictionary    ${jsondata}    revision
    [Return]    ${id}    ${revision}
