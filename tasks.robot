*** Settings ***
Documentation       Hi, This is for certificate level 2 robot
...                 For more information, check robocorp webpage

Library             RPA.Desktop
Library             RPA.Browser.Selenium    auto_close=${False}
Library             RPA.HTTP
Library             RPA.Tables
Library             RPA.Windows
Library             RPA.PDF


*** Variables ***
${DONWLOAD_PATH}        ${OUTPUT DIR}${/}Worklist.csv
${SCREENSHOT_PATH}      ${OUTPUT DIR}${/}RobotScreen.png


*** Tasks ***
Order robots from RobotSpareBin Industries Inc
    Open and loging to webpage
    Clik on popmelding
    Download csv file
    Read csv file and return a list
    Take Screenshot of the Order
#    Convert and save to PDF
#    Zip all pdf files
#    [Teardown]    Close All Applications

Minimal task
    Log    Done.


*** Keywords ***
Open and loging to webpage
    Open Available Browser    https://robotsparebinindustries.com/#/
    Input Text    username    maria
    Input Password    password    thoushallnotpass
    Submit Form
    Wait Until Page Contains Element    id:firstname
    Click Link    Order your robot!

Clik on popmelding
    Click Button    //*[@id="root"]/div/div[2]/div/div/div/div/div/button[1]

Download csv file
    Log    Downloading .CSV file
    Download    https://robotsparebinindustries.com/orders.csv    overwrite=True    target_file=${DONWLOAD_PATH}

Read csv file and return a list
    ${Liste}=    Read table from CSV    ${DONWLOAD_PATH}
    FOR    ${file}    IN    @{Liste}
        Order from webpage
        ...    ${file}[Order number]
        ...    ${file}[Body]
        ...    ${file}[Head]
        ...    ${file}[Legs]
        ...    ${file}[Address]
    END

Order from webpage
    [Arguments]    ${Ordernumaber}    ${Head}    ${Body}    ${Legs}    ${Address}
    Select From List By Value    id:head    ${Head}
    Select Radio Button    body    ${Body}
    Input Text    class:form-control    ${Legs}
    Input Text    id:address    ${Address}
    Click Button    id:preview
    Click Button    id:order
    Take Screenshot of the Order
    ${RECEIPT}=    Get Element Attribute    id:receipt    outerHTML
    Html To Pdf    ${RECEIPT}    ${Ordernumaber}.pdf
    Open Pdf    ${Ordernumaber}.pdf
    Add Watermark Image To Pdf    ${SCREENSHOT_PATH}    ${Ordernumaber}.pdf
    Close Pdf
    Click Button    id:order-another
    ${PopupMessage}=    Does Page Contain Button    //*[@id="root"]/div/div[2]/div/div/div/div/div/button[1]
    IF    ${PopupMessage}    Clik on popmelding

Take Screenshot of the Order
    Wait Until Element Is Visible    id:robot-preview
    RPA.Browser.Selenium.Screenshot    locator=id:robot-preview    filename=${SCREENSHOT_PATH}
