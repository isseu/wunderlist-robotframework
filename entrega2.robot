*** Settings ***
Documentation     Pruebas de API Wunderlist
# Library           Library.py
Library           Collections
Library           RequestsLibrary
Library           String
Library           BuiltIn

*** Variables ***
${API_URL}        http://a.wunderlist.com
${CLIENT ID}      59faafeee266cc5fac01
${CLIENT SECRET}  d8a8da5713d2f1be0d77eb68f4fc10dfa2e09f05c1801dfb797020f4b30b
&{AUTH_HEADERS}   X-Access-Token=${CLIENT SECRET}  X-Client-ID=${CLIENT ID}  Content-Type=application/json
# Wunderlist URLs
${API_USER_URL}          /api/v1/user
${API_TASKS_URL}         /api/v1/tasks
${API_TASKS_COMMENTS}    /api/v1/task_comments
${API_LISTS_URL}         /api/v1/lists
${API_FOLDERS_URL}       /api/v1/folders
${API_MEMBERSHIPS_URL}   /api/v1/memberships
${API_NOTES_URL}         /api/v1/notes
${API_REMINDERS_URL}      /api/v1/reminders

# Ocupar 4 espacios siempre
# Hay ejemplos aqui https://github.com/bulkan/robotframework-requests/blob/master/tests/testcase.txt
# Librerias RobotFramework http://robotframework.org/robotframework/latest/libraries/BuiltIn.html#Catenate

*** Test Cases ***

###########
## Tasks ##
###########

Get Completed Tasks From List
    Create Wunderlist Session
    ${id_list}    ${revision}     Get Any User List

    # BASE CASE  ---> Completed = False && List = Normal
    &{params}=    Create Dictionary    list_id=${id_list}    completed=false
    ${resp}=    Get Request    wunderlist    ${API_TASKS_URL}    params=${params}
    Should Be Equal As Strings    ${resp.status_code}    200

    # 1) Completed = True && List = Normal
    &{params}=    Create Dictionary    list_id=${id_list}    completed=true
    ${resp}=    Get Request    wunderlist    ${API_TASKS_URL}    params=${params}
    Should Be Equal As Strings    ${resp.status_code}    200

    # 2) Completed = Numero && List = Normal
    &{params}=    Create Dictionary    list_id=${id_list}    completed=1234
    ${resp}=    Get Request    wunderlist    ${API_TASKS_URL}    params=${params}
    Should Be Equal As Strings    ${resp.status_code}    200

    # 3) Completed = False && List = 409233670
    &{params}=    Create Dictionary    list_id=409233670   completed=false
    ${resp}=    Get Request    wunderlist    ${API_TASKS_URL}    params=${params}
    Should Be Equal As Strings    ${resp.status_code}    404

    # 4) Completed = False && List = hola mundo
    &{params}=    Create Dictionary    list_id=hola mundo    completed=false
    ${resp}=    Get Request    wunderlist    ${API_TASKS_URL}    params=${params}
    Should Be Equal As Strings    ${resp.status_code}    500


Get Tasks From List
    Create Wunderlist Session
    ${id_list}    ${revision}     Get Any User List

    # BASE CASE list_id = Con permiso
    &{params}=    Create Dictionary    list_id=${id_list}
    ${resp}=    Get Request    wunderlist    ${API_TASKS_URL}    params=${params}
    Should Be Equal As Strings    ${resp.status_code}    200

    # 1) list_id no nos pertenece
    &{params}=    Create Dictionary    list_id=409233670
    ${resp}=    Get Request    wunderlist    ${API_TASKS_URL}    params=${params}
    Should Be Equal As Strings    ${resp.status_code}    404

    # 2) list_id no es entero
    &{params}=    Create Dictionary    list_id=hola mundo
    ${resp}=    Get Request    wunderlist    ${API_TASKS_URL}    params=${params}
    Should Be Equal As Strings    ${resp.status_code}    500


##############
## Comments ##
##############

Create Comment on task
    Create Wunderlist Session
    ${id_list}    ${revision}     Get Any User List
    &{params}=    Create Dictionary    list_id=${id_list}    title=Creating Comment Task
    ${resp}=    Post Request    wunderlist    ${API_TASKS_URL}    data=${params}
    ${jsondata}=    To Json    ${resp.content}
    ${id_task}=    Get From Dictionary    ${jsondata}    id

    # BASE CASE task_id accesible && text no vacio
    &{params}=    Create Dictionary    task_id=${id_task}    text=First Comment
    ${resp}=    Post Request    wunderlist    ${API_TASKS_COMMENTS}    data=${params}
    Should Be Equal As Strings    ${resp.status_code}    201

    # 1) task_id no accesible && text no vacio
    &{params}=    Create Dictionary    task_id=409233670    text=First Comment
    ${resp}=    Post Request    wunderlist    ${API_TASKS_COMMENTS}    data=${params}
    Should Be Equal As Strings    ${resp.status_code}    400

    # 1) task_id no es numero && text no vacio
    &{params}=    Create Dictionary    task_id=hola    text=First Comment
    ${resp}=    Post Request    wunderlist    ${API_TASKS_COMMENTS}    data=${params}
    Should Be Equal As Strings    ${resp.status_code}    400

    # 2) task_id accesible && text vacio
    &{params}=    Create Dictionary    task_id=hola    text=
    ${resp}=    Post Request    wunderlist    ${API_TASKS_COMMENTS}    data=${params}
    Should Be Equal As Strings    ${resp.status_code}    400

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

Get Any Item
    [Arguments]    ${url}
    Create Wunderlist Session
    ${resp}=    Get Request    wunderlist    ${url}
    ${jsondata}=    To Json    ${resp.content}
    ${length}=    Get Length      ${jsondata}
    ${number}=    Evaluate    random.sample(range(1, ${length} - 1), 1)    random
    ${number}=    Get From List     ${number}     0
    ${result}=    Get From List    ${jsondata}    ${number}
    ${id}=    Get From Dictionary    ${result}    id
    [Return]    ${id}

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
