#SIGNSPACE CONNECTOR TESTS
*** Settings ***
Library           Collections
Library           DateTime
Library           PoTLib
Library           REST         ${POT_API_URL}


*** Variables ***
${POT_API_URL}               http://localhost:8080
# ${APP_TOKEN}                 %{POT_ACCESS_TOKEN_APP1}
# ${CLIENT_SECRET}             %{CLIENT_SECRET_WORLD}
# ${PRODUCT_CODE}              %{PRODUCT_CODE}
${TIMESTAMP}                 2018-11-01T12:00:00+00:00
${FIRST_STATUS}              Canceled
${SECOND_STATUS}             In Progress
${THIRD_STATUS}              Open
@{STATUSES}     ${FIRST_STATUS}    ${SECOND_STATUS}    ${THIRD_STATUS}

${ID_OFFICIAL}               3042282-9
${COUNTRY_CODE}              fi
${START_TIME}                2019-10-19T13:20:09+03:00
${START_TIME_LATE}           2020-06-06T13:20:09+03:00
${END_TIME}                  2020-06-04T10:53:54+03:00
${END_TIME_EARLY}            2019-11-19T13:20:09+03:00
${FILTER_TEST}               new
${LIMIT}                     5
${OFFSET}                    0
${QUERY_TEXT}
@{FILTER}                    
&{BROKER_BODY_PARAMETERS}    idOfficial=${ID_OFFICIAL}
...                          country=${COUNTRY_CODE}
...                          status=@{STATUSES}
...                          limit=${LIMIT}
...                          offset=${OFFSET}
...                          queryText=${QUERY_TEXT}
...                          filter=@{FILTER}
&{BROKER_BODY}               timestamp=${TIMESTAMP}
...                          parameters=${BROKER_BODY_PARAMETERS}

*** Keywords ***
Fetch Data Product
    [Arguments]     ${body}
    # ${signature}    Calculate PoT Signature          ${body}    ${CLIENT_SECRET}
    # Set Headers     {"x-pot-signature": "${signature}", "x-app-token": "${APP_TOKEN}"}
    POST            /translator/v1/fetch    ${body}
    Output schema   response body

Get Body
    [Arguments]          &{kwargs}
    ${body}              Copy Dictionary     ${BROKER_BODY}    deepcopy=True
    ${now}               Get Current Date    time_zone=UTC     result_format=%Y-%m-%dT%H:%M:%S+00:00
    Set To Dictionary    ${body}             timestamp         ${now}
    Set To Dictionary    ${body}             &{kwargs}
    ${json_string}=      evaluate        json.dumps(${body})                 json
    [Return]             ${json_string}


*** Test Cases ***
fetch, 200
    ${body}               Get Body
    Fetch Data Product    ${body}
    Integer     response status                                                 200
    String      response body @context                                          https://standards-ontotest.oftrust.net/v2/Context/DataProductOutput/Document/Signing/SignSpace/
    # First task fetch tests
    String      response body data signing 0 url                                https://signspace.beta.tilaajavastuu.fi/signing/5eda1409d5ca82017ea96a66
    Number      response body data signing 0 digitalSignaturesRequestedCount    1
    Number      response body data signing 0 digitalSignaturesCompletedCount    0
    String      response body data signing 0 created                            2020-06-05T09:44:41
    String      response body data signing 0 updated                            2020-06-05T09:55:42
    String      response body data signing 0 status                             Canceled
    String      response body data signing 0 idSource                           5eda1409d5ca82017ea96a66
    String      response body data signing 0 name                               Test contract with tag
    String      response body data signing 0 parties 0 @type                    Organization
    String      response body data signing 0 parties 0 name                     PoT Beta
    String      response body data signing 0 parties 1 @type                    Organization
    String      response body data signing 0 parties 1 name                     PoT Beta
    String      response body data signing 0 documents 0 @type                  Document
    String      response body data signing 0 documents 0 name                   bar.png
    Array       response body data signing 0 digitalSignatures                  maxItems=0
    # Second task fetch tests
    String      response body data signing 1 url                                https://signspace.beta.tilaajavastuu.fi/signing/5ed0a1b3588e433c01328ad8
    Number      response body data signing 1 digitalSignaturesRequestedCount    1
    Number      response body data signing 1 digitalSignaturesCompletedCount    0
    String      response body data signing 1 created                            2020-05-29T05:46:27
    String      response body data signing 1 updated                            2020-05-29T05:46:27
    String      response body data signing 1 status                             Open
    String      response body data signing 1 idSource                           5ed0a1b3588e433c01328ad8
    String      response body data signing 1 name                               Test
    String      response body data signing 1 parties 0 @type                    Organization
    String      response body data signing 1 parties 0 name                     PoT Beta
    String      response body data signing 1 documents 0 @type                  Document
    String      response body data signing 1 documents 0 name                   resume.doc
    Array       response body data signing 1 digitalSignatures                  maxItems=0
    # Third task fetch tests
    String      response body data signing 2 url                                https://signspace.beta.tilaajavastuu.fi/signing/5ec24715a73c170181da9767
    Number      response body data signing 2 digitalSignaturesRequestedCount    2
    Number      response body data signing 2 digitalSignaturesCompletedCount    1
    String      response body data signing 2 created                            2020-05-18T08:28:05
    String      response body data signing 2 updated                            2020-05-18T08:35:40
    String      response body data signing 2 status                             In progress
    String      response body data signing 2 idSource                           5ec24715a73c170181da9767
    String      response body data signing 2 name                               ABC
    String      response body data signing 2 parties 0 @type                    Organization
    String      response body data signing 2 parties 0 name                     PoT Beta
    String      response body data signing 2 parties 1 @type                    Organization
    String      response body data signing 2 parties 1 name                     PoT Beta
    String      response body data signing 2 documents 0 @type                  Document
    String      response body data signing 2 documents 0 name                   the-fellowship-of-the-ring-j-r-r-tolkien.pdf
    String      response body data signing 2 digitalSignatures 0 @type          DigitalSignature
    String      response body data signing 2 digitalSignatures 0 executor       simeon.platonov@gmail.com
    String      response body data signing 2 digitalSignatures 0 timestamp      2020-05-18T08:35:40
    # Fourth task fetch tests
    String      response body data signing 3 url                                https://signspace.beta.tilaajavastuu.fi/signing/5ec2200df6421916a83708bf
    Number      response body data signing 3 digitalSignaturesRequestedCount    1
    Number      response body data signing 3 digitalSignaturesCompletedCount    0
    String      response body data signing 3 created                            2020-05-18T05:41:33
    String      response body data signing 3 updated                            2020-05-18T08:27:17
    String      response body data signing 3 status                             Canceled
    String      response body data signing 3 idSource                           5ec2200df6421916a83708bf
    String      response body data signing 3 name                               
    String      response body data signing 3 parties 0 @type                    Organization
    String      response body data signing 3 parties 0 name                     PoT Beta
    String      response body data signing 3 documents 0 @type                  Document
    String      response body data signing 3 documents 0 name                   pohjapiirros.pdf

fetch, 422, Missing data for parameters required field
    ${body}                Get Body
    ${body}=             evaluate        json.loads('''${body}''')    json
    Pop From Dictionary    ${body}                              parameters
    Fetch Data Product     ${body}
    Integer     response status                                                 422
    Integer     response body error status                                      422
    String      response body error message parameters.idOfficial 0
    ...                                                                         Missing data for required field.
    String      response body error message parameters.country 0
    ...                                                                         Missing data for required field.

fetch, 422, filter as string => Not a valid list
    ${body}                Get Body
    ${body}=             evaluate        json.loads('''${body}''')    json
    Set To Dictionary      ${body["parameters"]}                filter="new"
    Fetch Data Product     ${body}
    Integer     response status                                                 422
    Integer     response body error status                                      422
    String      response body error message
    ...                                                                         Filter must be an Array

fetch, 200, status as empty list => Returns all statuses
    ${body}                Get Body
    ${body}=             evaluate        json.loads('''${body}''')    json
    ${EMPTY_LIST}       Create List         ${EMPTY}
    Set To Dictionary      ${body["parameters"]}                status=${EMPTY_LIST}
    ${body}=      evaluate        json.dumps(${body})                 json
    Fetch Data Product     ${body}
    Integer     response status                                                 200

fetch, 422, limit as 0 => Not an actual limiting Number
    ${body}                Get Body
    ${body}=             evaluate        json.loads('''${body}''')    json
    Set To Dictionary      ${body["parameters"]}                limit=
    Fetch Data Product     ${body}
    Integer     response status                                                 422
    Integer     response body error status                                      422
    String      response body error message
    ...                                                                         Please set limit above 0

fetch, 200, startTime returns tasks started after
    ${body}                Get Body
    ${body}=             evaluate        json.loads('''${body}''')              json
    Set To Dictionary      ${body["parameters"]}                                startTime=${START_TIME}
    ${body}=             evaluate        json.dumps(${body})                    json
    Fetch Data Product     ${body}
    Integer     response status                                                 200     
    String      response body data signing 0 created                            2020-06-05T09:44:41
    String      response body data signing 1 created                            2020-05-29T05:46:27   
    String      response body data signing 2 created                            2020-05-18T08:28:05
    String      response body data signing 3 created                            2020-05-18T05:41:33


fetch, 200, late startTime returns empty tasks array
    ${body}                Get Body
    ${body}=             evaluate        json.loads('''${body}''')              json
    Set To Dictionary      ${body["parameters"]}                                startTime=${START_TIME_LATE}
    ${body}=             evaluate        json.dumps(${body})                    json
    Fetch Data Product     ${body}
    Integer     response status                                                 200
    Array       response body data signing                                      maxItems=0

fetch, 200, endTime returns tasks started before
    ${body}                Get Body
    ${body}=             evaluate        json.loads('''${body}''')              json
    Set To Dictionary      ${body["parameters"]}                                endTime=${END_TIME}
    ${body}=             evaluate        json.dumps(${body})                    json
    Fetch Data Product     ${body}
    Integer     response status                                                 200     
    String      response body data signing 0 created                            2020-05-29T05:46:27   
    String      response body data signing 1 created                            2020-05-18T08:28:05
    String      response body data signing 2 created                            2020-05-18T05:41:33


fetch, 200, early endTime returns empty tasks array
    ${body}                Get Body
    ${body}=             evaluate        json.loads('''${body}''')              json
    Set To Dictionary      ${body["parameters"]}                                endTime=${END_TIME_EARLY}
    ${body}=             evaluate        json.dumps(${body})                    json
    Fetch Data Product     ${body}
    Integer     response status                                                 200
    Array       response body data signing                                      maxItems=0

fetch, 200, multiple time values
    ${body}                Get Body
    ${body}=             evaluate        json.loads('''${body}''')              json
    Set To Dictionary      ${body["parameters"]}                startTime=${START_TIME}
    Set To Dictionary      ${body["parameters"]}                endTime=${END_TIME}
    ${body}=             evaluate        json.dumps(${body})                    json
    Fetch Data Product     ${body}
    Integer     response status                                                 200
    Array       response body data signing                                      minItems=3    maxItems=3

fetch, 422, startTime is bigger than endTime
    ${body}                Get Body
    ${body}=             evaluate        json.loads('''${body}''')    json
    Set To Dictionary      ${body["parameters"]}                startTime=${END_TIME}
    Set To Dictionary      ${body["parameters"]}                endTime=${START_TIME}
    ${body}=             evaluate        json.dumps(${body})                    json
    Fetch Data Product     ${body}
    Integer     response status                                                 422
    Integer     response body error status                                      422
    String      response body error message                                     Notice, endTime should be after the startTime

fetch, 422, missing data from idOfficial required field
    ${body}                Get Body
    ${body}=             evaluate        json.loads('''${body}''')    json
    Pop From Dictionary    ${body["parameters"]}                idOfficial
    Fetch Data Product     ${body}
    Integer     response status                                                 422
    Integer     response body error status                                      422
    String      response body error message parameters.idOfficial 0
    ...                                                                         Missing data for required field.

fetch, 422, missing data from country required field
    ${body}                Get Body
    ${body}=             evaluate        json.loads('''${body}''')    json
    Pop From Dictionary    ${body["parameters"]}                country
    Fetch Data Product     ${body}
    Integer     response status                                                 422
    Integer     response body error status                                      422
    String      response body error message parameters.country 0
    ...                                                                         Missing data for required field.
