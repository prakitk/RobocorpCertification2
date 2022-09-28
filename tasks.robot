*** Settings ***
Documentation       Hi, This is for certificate level 2 robot
...                 For more information, check robocorp webpage

Library             RPA.Desktop
Library             RPA.Browser.Selenium    auto_close=${False}
Library             RPA.HTTP
Library             RPA.Tables
Library             RPA.Windows
Library             RPA.PDF
Library             RPA.Archive
Library             RPA.Dialogs


*** Variables ***
### File names and Paths
${DONWLOAD_PATH}        ${OUTPUT DIR}${/}Worklist.csv
${SCREENSHOT_PATH}      ${OUTPUT DIR}${/}RobotScreen.png
${PDFFOLDER}            ${OUTPUT_DIR}/PDFs/

### GOBAL VARIABLES
${WEBPAGE}              https://robotsparebinindustries.com/#/
${USERNAME}             maria
${PASSWORD}             thoushallnotpass
${WEBPAGECSV}           https://robotsparebinindustries.com/orders.csv


*** Tasks ***
Order robots from RobotSpareBin Industries Inc
    ${webpage_csv_input}=    Ask user for CSV URL
    Open and loging to webpage
    Download csv file    ${webpage_csv_input}
    ${CSVLIST}=    Reading CSV to list
    FOR    ${file}    IN    @{CSVLIST}
        Order from webpage
        ...    ${file}[Order number]
        ...    ${file}[Body]
        ...    ${file}[Head]
        ...    ${file}[Legs]
        ...    ${file}[Address]
    END
    Create Zip file
#    [Teardown]    Close All Applications

Minimal task
    Log    Done.


*** Keywords ***
Open and loging to webpage
    Log    Open webpage and login
    Open Available Browser    ${WEBPAGE}
    Input Text    username    ${USERNAME}
    Input Password    password    ${PASSWORD}
    Submit Form
    Wait Until Page Contains Element    id:firstname
    Click Link    Order your robot!
    Clik on PopupMessage

Clik on PopupMessage
    Log    Pop Message Found! Clicking on it!
    Click Button    //*[@id="root"]/div/div[2]/div/div/div/div/div/button[1]

Download csv file
    [Arguments]    ${webpage_csv_input}
    Log    Downloading .CSV file
    Download    ${webpage_csv_input}    overwrite=True    target_file=${DONWLOAD_PATH}

Reading CSV to list
    ${CSVLIST}=    Read table from CSV    ${DONWLOAD_PATH}
    RETURN    ${CSVLIST}

Order from webpage
    [Arguments]    ${Ordernumaber}    ${Head}    ${Body}    ${Legs}    ${Address}
    Select From List By Value    id:head    ${Head}
    Select Radio Button    body    ${Body}
    Input Text    class:form-control    ${Legs}
    Input Text    id:address    ${Address}
    Click Button    id:preview
    Wait Until Keyword Succeeds    6x    1 sec    Click order and check receipt
    Take Screenshot of the Order
    Create PDF file    ${Ordernumaber}

    Click Button    id:order-another
    ${PopupMessage}=    Does Page Contain Button    //*[@id="root"]/div/div[2]/div/div/div/div/div/button[1]
    IF    ${PopupMessage}    Clik on PopupMessage

Take Screenshot of the Order
    Wait Until Element Is Visible    id:robot-preview
    RPA.Browser.Selenium.Screenshot    locator=id:robot-preview    filename=${SCREENSHOT_PATH}

Create Zip file
    ${PDFZIPFILE}=    Set Variable    ${OUTPUT_DIR}/PDFs.zip
    Archive Folder With Zip    ${PDFFOLDER}    ${PDFZIPFILE}

Create PDF file
    [Arguments]    ${Ordernumaber}
    ${receipt}=    Get Element Attribute    id:receipt    outerHTML
    ${filename}=    Set Variable    ${PDFFOLDER}${Ordernumaber}.pdf
    Html To Pdf    ${receipt}    ${filename}
    Open Pdf    ${filename}
    Add Watermark Image To Pdf    ${SCREENSHOT_PATH}    ${filename}
    Close Pdf

Click order and check receipt
    Click Button    id:order
    Click Element    id:receipt

Ask user for CSV URL
    Add heading    Please provide URL to CSV file
    Add text input    url    label=CSV URL:
    ${result}=    Run dialog
