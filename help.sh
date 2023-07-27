#!/bin/bash

BBlue='\033[1;34m'
Color_Off='\033[0m'
BRed='\033[1;31m'
BYellow='\033[1;33m'
BPurple='\033[1;35m'
BGreen='\033[1;32m'
ICyan='\033[0;96m'

REGISTER_INFO() {
  #TRACE_ID=$(GET_TIMESTAMP)
  cat /etc/lowes/config/touchpoint.json | jq '"\(.storeNumber) : \(.hostname)"'
}

GET_TIMESTAMP() {
  echo "$(date +"%Y-%m-%dT%H:%M:%S%z")"
}

GET_REGISTER() {
  TRACE_ID=$(GET_TIMESTAMP)
  curl --connect-timeout 10 -s -H "x-b3-traceid: TPT-$TRACE_ID" -H "x-b3-spanid: $TRACE_ID" https://localhost/tachyon/v2/register | jq
}

TOUCHPOINT_DETAILS() {
  TRACE_ID=$(GET_TIMESTAMP)
  curl --connect-timeout 10 -s -H "x-b3-traceid: TPT-$TRACE_ID" -H "x-b3-spanid: $TRACE_ID" https://localhost/tachyon/v2/register | jq 'del(.peripherals)'
}

PERIPHERALS_DETAILS() {
  TRACE_ID=$(GET_TIMESTAMP)
  echo "$TRACE_ID"
  curl --connect-timeout 10 -s -H "x-b3-traceid: TPT-$TRACE_ID" -H "x-b3-spanid: $TRACE_ID" https://localhost/tachyon/v2/register | jq '.peripherals'
}

RESET_PERIPHERAL() {
  #echo "Resetting..."
  TRACE_ID=$(GET_TIMESTAMP)
  curl --connect-timeout 10 -s -X 'PUT' \
    "https://localhost/tachyon/v2/register/peripherals/category/$1/reset" \
    -H 'accept: application/json' \
    -H "x-b3-traceid: TPT-$TRACE_ID" \
    -H "x-b3-spanid: $TRACE_ID" | jq
}

RESET_PRINTER_XD() {
  curl --connect-timeout 10 -s -X 'PUT' \
    "https://localhost/tachyon/v2/register/peripherals/category/printer/configure" \
    -H 'accept: application/json' \
    -H 'x-b3-traceid: 6dc33ac0-6c82-44va-b0a1-e05e7659d70b' \
}

RESET_RECYCLER() {
  TRACE_ID=$(GET_TIMESTAMP)
  CR_ID=$(cat /etc/lowes/config/touchpoint.json | jq '"GLORY-CI10-glory-\(.tags.ASSOCIATED_CR).\(.storeNumber).lowes.com"' | tr -d '"')
  curl --connect-timeout 10 -s -X PUT \
    "https://localhost/tachyon/v2/register/peripherals/$CR_ID/reset" \
    --header "x-b3-traceid: TPT-$TRACE_ID" \
    --header "x-b3-spanid: $TRACE_ID" \
    --header 'Cache-Control: no-cache' | jq
}

STOP_MRV_APPS() {
  TRACE_ID=$(GET_TIMESTAMP)
  STATUS=$(curl -i -s -o /dev/null -w "%{http_code}" --location --request PUT \
    'http://localhost:3430/tachyonx/v1/apps/forceClose' \
    --header "x-b3-traceId: TPT-$TRACE_ID" \
    --header "x-b3-spanId: $TRACE_ID")

  #echo $STATUS
}

RESTART_TACHYONX() {
  sudo systemctl restart app-platform
  echo $ICyan"Triggered  restart...$Color_Off"

  #  curl \
  #--header 'x-b3-traceId: random-trace-id' \
  #--header 'x-b3-spanId: random-span-id' \
  #-s -o /dev/null -w "%{http_code}" --request PUT "http://localhost:3430/tachyonx/v1/apps/forceClose"
}

REBOOT_REGISTER() {
  sleep 2
  sudo reboot -f
}

TEST_PRINT() {
  TRACE_ID=$(GET_TIMESTAMP)
  curl --connect-timeout 10 -s -X 'PUT' \
    'https://localhost/tachyon/v2/register/peripherals/category/printer/testprint/SALE' \
    -H 'accept: application/json' \
    -H "x-b3-traceid: TPT-$TRACE_ID" \
    -H "x-b3-spanid: $TRACE_ID" | jq
}

VALIDATE_RESULT() {
  if [ "$1" = "true" ]; then
    echo $BGreen"$2: Reset success $Color_Off"
  else
    echo $BRed"$2: Reset failed $Color_Off"
  fi
}

PRINT_CENTER() {
  COLUMNS=$(tput cols)
  title=$1
  printf "%*s\n" $(((${#title} + $COLUMNS) / 2)) "$title"
}

OPEN_CASH_DRAWER() {
  TRACE_ID=$(GET_TIMESTAMP)
  curl --connect-timeout 10 -s -X 'PUT' \
    "https://localhost/tachyon/v2/register/peripherals/category/cash-drawer/open" \
    -H 'accept: application/json' \
    -H "x-b3-traceid: TPT-$TRACE_ID" \
    -H "x-b3-spanid: $TRACE_ID" | jq
}

DISPLAY_WELCOME_ON_PED() {
  TRACE_ID=$(GET_TIMESTAMP)
  curl --connect-timeout 10 -s -X 'PUT' \
    "https://localhost/tachyon/v2/register/peripherals/category/ped/welcome" \
    -H 'accept: application/json' \
    -H "x-b3-traceid: TPT-$TRACE_ID" \
    -H "x-b3-spanid: $TRACE_ID" | jq
}

CLEAR_PED() {
  TRACE_ID=$(GET_TIMESTAMP)
  curl --connect-timeout 10 -s -X 'PUT' \
    "https://localhost/tachyon/v2/register/peripherals/category/ped/clear-screen" \
    -H 'accept: application/json' \
    -H "x-b3-traceid: TPT-$TRACE_ID" \
    -H "x-b3-spanid: $TRACE_ID" | jq
}

DISPLAY_WELCOME_ON_POLE() {
  TRACE_ID=$(GET_TIMESTAMP)
  curl --connect-timeout 10 -s -X 'PUT' \
    "https://localhost/tachyon/v2/register/peripherals/category/pole/display" \
    -d '{"messages": ["Welcome"]}' \
    -H 'Content-Type: application/json' \
    -H "x-b3-traceid: TPT-$TRACE_ID" \
    -H "x-b3-spanid: $TRACE_ID" | jq
}

CLEAR_POLE() {
  TRACE_ID=$(GET_TIMESTAMP)
  curl --connect-timeout 10 -s -X 'PUT' \
    "https://localhost/tachyon/v2/register/peripherals/category/pole/display" \
    -d '{"messages": []}' \
    -H 'Content-Type: application/json' \
    -H "x-b3-traceid: TPT-$TRACE_ID" \
    -H "x-b3-spanid: $TRACE_ID" | jq
}

RESET_ALL_PERIPHERALS() {
  TRACE_ID=$(GET_TIMESTAMP)
  curl --connect-timeout 10 -s -X 'PUT' \
    "https://localhost/tachyon/v2/register/peripherals/reset" \
    -H 'accept: application/json' \
    -H "x-b3-traceid: TPT-$TRACE_ID" \
    -H "x-b3-spanid: $TRACE_ID" | jq
}

TEST_STANDARD_INPUT() {
  read -p "Waiting for input  : " line
  echo "$line"
}

TEST_PED_KEYS() {
  TRACE_ID=$(GET_TIMESTAMP)
  STOP_MRV_APPS
  curl -s --connect-timeout 10 --location --request PUT \
    'https://localhost/tachyon/v2/register/peripherals/ped/verifone/test-keypad' \
    -H "x-b3-traceid: TPT-$TRACE_ID" \
    -H "x-b3-spanid: $TRACE_ID" | jq
}

TEST_SIGNATURE_ON_PED() {
  TRACE_ID=$(GET_TIMESTAMP)
  STOP_MRV_APPS
  curl -s --connect-timeout 10 --location --request PUT \
    'https://localhost/tachyon/v2/register/peripherals/ped/verifone/signature' \
    -d '{"messages" : ["test"],"timeout" : 120000}' \
    -H "x-b3-traceid: TPT-$TRACE_ID" \
    -H "x-b3-spanid: $TRACE_ID" \
    -H 'Content-Type: application/json' | jq
}

ACTIVATE_PAYMENT() {
  TRACE_ID=$(GET_TIMESTAMP)
  curl -s --connect-timeout 10 --location --request POST 'https://localhost/tachyon/v2/register/payments/activate' \
    -o /dev/null \
    -d '{"paymentModes": ["CARD"]}' \
    -H "x-b3-traceid: TPT-$TRACE_ID" \
    -H "x-b3-spanid: $TRACE_ID" \
    -H 'Content-Type: application/json'
}

ACTIVATE_CHECKREADER() {
  TRACE_ID=$(GET_TIMESTAMP)
  curl -s --connect-timeout 10 --location --request POST 'https://localhost/tachyon/v2/register/peripherals/category/check-reader/activate' \
    -o /dev/null \
    -d '{"paymentModes": ["CHECK"]}' \
    -H "x-b3-traceid: TPT-$TRACE_ID" \
    -H "x-b3-spanid: $TRACE_ID" \
    -H 'Content-Type: application/json' | jq 
}

EXECUTE_CHECKFRANK() {
  TRACE_ID=$(GET_TIMESTAMP)
  output=$(curl -s --connect-timeout 15 --location --request PUT 'https://localhost/tachyon/v2/register/peripherals/category/check-reader/frank'  \
    -d '{"data": "This is test frank"}' \
    -H "x-b3-traceid: TPT-$TRACE_ID" \
    -H "x-b3-spanid: $TRACE_ID" \
    -H 'Content-Type: application/json' | jq)
  output=$(echo $output | jq .peripherals[0].status)
  if [ "$output" = "true" ]; then
    echo "CHECK FRANK SUCCESS"
  else
    echo "CHECK FRANK $BRed FAILURE"
  fi
}

DEACTIVATE_CHECKREADER() {
  TRACE_ID=$(GET_TIMESTAMP)
  curl -s --connect-timeout 10 --location --request POST 'https://localhost/tachyon/v2/register/peripherals/category/check-reader/deactivate' \
    -o /dev/null \
    -d '{"paymentModes": ["CHECK"]}' \
    -H "x-b3-traceid: TPT-$TRACE_ID" \
    -H "x-b3-spanid: $TRACE_ID" \
    -H 'Content-Type: application/json' | jq
}

DEACTIVATE_PAYMENT() {
  TRACE_ID=$(GET_TIMESTAMP)
  curl -s --connect-timeout 10 --location --request POST 'https://localhost/tachyon/v2/register/payments/deactivate' \
    -o /dev/null \
    -d '{"paymentModes": ["CARD"]}' \
    -H "x-b3-traceid: TPT-$TRACE_ID" \
    -H "x-b3-spanid: $TRACE_ID" \
    -H 'Content-Type: application/json'
}

WEB_SOCKET_SUBSCRIBE() {
  curl -s \
    --include \
    --no-buffer \
    --header "Connection: Upgrade" \
    --header "Upgrade: websocket" \
    --header "Host: localhost" \
    --header "Origin: http://localhost" \
    --header "Sec-WebSocket-Key: SGVsbG8sIHdvcmxkIQ==" \
    --header "Sec-WebSocket-Version: 13" \
    https://localhost/tachyon/v1/till/messages/subscribe?message-type=TENDER_CAPTURE\&x-b3-traceid=12356\&x-b3-spanid=12345678 >${PWD}/ws.log &
}

WEB_SOCKET_UNSUBSCRIBE() {
  echo ""
}

TEST_CARD_CAPTURE() {
  TRACE_ID=$(GET_TIMESTAMP)

  STOP_MRV_APPS
  WEB_SOCKET_SUBSCRIBE
  ACTIVATE_PAYMENT

  FILE_SIZE=$(wc -c ${PWD}/ws.log | awk '{print $1}')

  max=30
  for i in $(seq 1 $max); do
    sleep 1
    if [ ! "$(wc -c ${PWD}/ws.log | awk '{print $1}')" -eq "$FILE_SIZE" ]; then
      break
    fi
  done

  DEACTIVATE_PAYMENT
  #WEB_SOCKET_UNSUBSCRIBE

  if grep -q "TENDER_CAPTURE" ${PWD}/ws.log; then
    echo "CARD CAPTURE SUCCESS"
  else
    echo "CARD CAPTURE $BRed FAILURE"
  fi
}

TEST_CHECK_SCAN() {
  TRACE_ID=$(GET_TIMESTAMP)
  list=$(curl --connect-timeout 10 -s -H "x-b3-traceid: TPT-$TRACE_ID" -H "x-b3-spanid: $TRACE_ID" https://localhost/tachyon/v2/register | jq '.paymentModes.available')
  echo $list | grep -w -q "CHECK"
  
  if [ $? -eq 0 ]; then
    STOP_MRV_APPS
    WEB_SOCKET_SUBSCRIBE
    ACTIVATE_CHECKREADER

    FILE_SIZE=$(wc -c ${PWD}/ws.log | awk '{print $1}')

    max=30
    for i in $(seq 1 $max); do
      sleep 1
      if [ ! "$(wc -c ${PWD}/ws.log | awk '{print $1}')" -eq "$FILE_SIZE" ]; then
        break
      fi
    done

    DEACTIVATE_CHECKREADER
    WEB_SOCKET_UNSUBSCRIBE

    if [ -s ${PWD}/ws.log ]; then
    var=$(grep -o -P -a '(?<="message":).*(?=reasonCodes)' ${PWD}/ws.log)
      if [ $? -eq 0 ]; then
        var="${var%%,*}"
        echo "CHECK SCAN $BRed FAILURE"
        echo "FAILURE REASON : $var"
      else
        echo "CHECK SCAN SUCCESS"
        var=$(grep -o -P -a '(?<="micrData":).*?(?="checkNumber")' ${PWD}/ws.log)
        var="${var%%,*}"
        echo "CHECK DATA :  $var"
      fi
    else
      echo "CHECK SCAN $BRed FAILURE"
      echo "FAILURE REASON : \"No check inserted\""

    fi
  else
    echo "$BRed CHECK READER NOT AVAILABLE" 
  fi
  rm -rf ${PWD}/ws.log
}

TEST_CHECK_FRANK() {
  TRACE_ID=$(GET_TIMESTAMP)
  list=$(curl --connect-timeout 10 -s -H "x-b3-traceid: TPT-$TRACE_ID" -H "x-b3-spanid: $TRACE_ID" https://localhost/tachyon/v2/register | jq '.paymentModes.available')
  echo $list | grep -w -q "CHECK"

  if [ $? -eq 0 ]; then
    STOP_MRV_APPS
    EXECUTE_CHECKFRANK
    DEACTIVATE_CHECKREADER
  else
    echo "$BRed CHECK READER NOT AVAILABLE"
  fi
}

RESOLVE_APP_NOT_SUPPORTED() {
  RESTART_TACHYONX > /dev/null

  #Reset to ensure the PED is not in transaction.
  RESET_PERIPHERAL "ped"
  
  RESULT=$(STORE_FILE_INGENICO)
  # check errors
  ERR_CODE=$(echo "$RESULT" | jq -r ".code")
  if [ -z "$ERR_CODE" ]; then
    EXECUTE_CONFIG

    RESPONSE=$(REBOOT_INGENICO_PED)
    # check errors
    ERR_CODE=$(echo "$RESULT" | jq -r ".code")
    if [ -z "$ERR_CODE" ]; then
      CMD_RESULT="Please wait at least 2 minutes for the ped to reboot"
    else
      CMD_RESULT="$RESULT"
    fi
  else
    if [ "$ERR_CODE" = "DEV_UNAVAILABLE" ]; then
      CMD_RESULT="$BRed PED connected is not Ingenico Lane 7000"
    else
      CMD_RESULT="$RESULT"
    fi
  fi

  echo "$CMD_RESULT"
}

STORE_FILE_INGENICO() {
  ACTION "Storing EMVCONTACT.XML file into the ped" > /dev/tty
   
  TRACE_ID=$(GET_TIMESTAMP)
  curl -s --connect-timeout 10 --location --request PUT 'https://localhost/tachyon/v2/register/peripherals/ped/ingenico/store-file' \
      -H "x-b3-traceId: TPT-${TRACE_ID}" \
      -H "x-b3-spanId: ${TRACE_ID}" \
      -H 'Content-Type: application/json' \
      -d '{"fileName": "classpath:ped/ingenico/EMVCONTACT.XML", "fileDestination": "/HOST/EMVCONTACT.XML", "overrideFlag":"1"}' | jq
}

EXECUTE_CONFIG() {
  TRACE_ID=$(GET_TIMESTAMP)
  response_code=$(curl -s --connect-timeout 10 --location --request PUT -w "%{http_code}" 'https://localhost/tachyon/v2/register/peripherals/ped/ingenico/execute-config' \
      -H "x-b3-traceId: TPT-${TRACE_ID}" \
      -H "x-b3-spanId: TPT-${TRACE_ID}" \
      -H "Content-Type: application/json" \
      -H "Cache-Control: no-cache" \
      -d "{}")

  if [ $response_code -ne 204 ] ; then
      #Retry once on failure.
      sleep 1
      response_code=$(curl -s --connect-timeout 10 --location --request PUT -w "%{http_code}" 'https://localhost/tachyon/v2/register/peripherals/ped/ingenico/execute-config' \
          -H "x-b3-traceId: TPT-${TRACE_ID}" \
          -H "x-b3-spanId: TPT-${TRACE_ID}" \
          -H "Content-Type: application/json" \
          -H "Cache-Control: no-cache" \
          -d "{}")
  fi
}


REBOOT_INGENICO_PED() {
  ACTION "Rebooting ped" > /dev/tty
  TRACE_ID=$(GET_TIMESTAMP)

  curl -s --connect-timeout 10 --location --request PUT 'https://localhost/tachyon/v2/register/peripherals/ped/ingenico/reboot' \
  -H "x-b3-traceId: TPT-${TRACE_ID}" \
  -H "x-b3-spanId: ${TRACE_ID}" \
  -H "Content-Type: application/json" \
  -d '{}' | jq
}

UPDATE_PACKAGES_CONFIGS_FOR_VERIFONE_PED() {
  TRACE_ID=$(GET_TIMESTAMP)

  RESULT=$(curl -s --connect-timeout 10 --location --request PUT 'https://localhost/tachyon/v2/register/peripherals/ped/verifone/update-packages-configs' \
      -H "x-b3-traceId: TPT-${TRACE_ID}" \
      -H "x-b3-spanId: ${TRACE_ID}" | jq)

  # check errors
  ERR_CODE=$(echo "$RESULT" | jq -r ".code")
  if [ -z "$ERR_CODE" ]; then
    echo $ICyan"Packages and Configs updated successfully $Color_Off" > /dev/tty
    RESULT="Please wait for the ped to reboot completely"
  fi

  echo "$RESULT"
}

BANNER() {
  clear
  REG=$(REGISTER_INFO)
  if [ ! "$REG" ]; then
    echo ""
    echo "$BRed ERROR: Register not up... $Color_Off"
    echo "$BYellow Exiting... $Color_Off"
    sleep 3
    exit 1
  fi
  echo "$BPurple"
  PRINT_CENTER "Welcome to TOUCHPOINT-SUPPORT tool on"
  PRINT_CENTER "$REG"
  echo "$Color_Off"
}

MENU() {
__menu="
List of available Options
----------------------------
1.  - TOUCHPOINT DETAILS 			11. - TEST CARD CAPTURE
2.  - PERIPHERALS DETAILS 			12. - RESET PED RESET         
3.  - TEST PRINT 			        13. - RESET CASH RECYCLER         
4.  - DISPLAY WELCOME ON POLE  			14. - RESET ALL PERIPHERALS       
5.  - CLEAR POLE SCREEN 			15. - RESTART TACHYONX     
6.  - DISPLAY WELCOME ON PED 			16. - REBOOT TOUCHPOINT         
7.  - CLEAR PED SCREEN 				17. - TEST CHECK SCAN 
8.  - TEST STANDARD INPUT 			18. - TEST CHECK FRANK
9.  - TEST PED KEYPAD			        19. - RESOLVE APP NOT SUPPORTED
10. - TEST SIGNATURE ON PED                     20. - UPDATE PACKAGES & CONFIGS ON VERIFONE M400/MX925
"
  echo "${BBlue} $__menu"
  echo "$Color_Off  ${BRed}"
  echo "99. - EXIT $Color_Off"
}

ACTION() {
  echo $ICyan"$1... $Color_Off"
}

USER_OPTION="0"
CMD_RESULT="0"
OPERATION=""

MAIN() {
  while [ "$USER_OPTION" != "99" ]; do
    clear
    BANNER
    MENU
    if [ "$CMD_RESULT" != "0" ]; then
      echo "----------------------------"
      echo "Selected Option :$BYellow $OPERATION $Color_Off"
      echo ""
      echo "Response :$BGreen"
      echo "$CMD_RESULT"
      echo "$Color_Off----------------------------"
    fi

    if [ "$OPERATION" = "TOUCHPOINT DETAILS" ] || [ "$OPERATION" = "PERIPHERALS DETAILS" ] || \
	    [ "$OPERATION" = "TEST CHECK SCAN" ] || [ "$OPERATION" = "TEST CHECK FRANK" ] || [ "$OPERATION" = "RESOLVE APP NOT SUPPORTED" ]; then
      MENU
    fi

    read -p "Enter your option : " USER_OPTION

    case $USER_OPTION in
    1)
      ACTION "Getting TOUCHPOINT Details"
      OPERATION="TOUCHPOINT DETAILS"
      CMD_RESULT=$(TOUCHPOINT_DETAILS)
      sleep 2
      ;;
    2)
      ACTION "Getting Peripheral Details"
      OPERATION="PERIPHERALS DETAILS"
      CMD_RESULT=$(PERIPHERALS_DETAILS)
      sleep 2
      ;;
    3)
      ACTION "Printing TEST-SALE Receipt"
      CMD_RESULT=$(TEST_PRINT)
      sleep 2
      OPERATION="TEST PRINT"
      ;;
    4)
      ACTION "Displaying on POLE"
      CMD_RESULT=$(DISPLAY_WELCOME_ON_POLE)
      sleep 2
      OPERATION="DISPLAY ON POLE"
      ;;
    5)
      ACTION "Clearing POLE Screen"
      CMD_RESULT=$(CLEAR_POLE)
      sleep 2
      OPERATION="CLEAR POLE"
      ;;
    6)
      ACTION "Displaying on PED"
      CMD_RESULT=$(DISPLAY_WELCOME_ON_PED)
      sleep 2
      OPERATION="DISPLAY ON PED"
      ;;
    7)
      ACTION "Clearing PED Screen"
      CMD_RESULT=$(CLEAR_PED)
      sleep 2
      OPERATION="CLEAR PED"
      ;;
    8)
      ACTION "Testing Standard Input"
      CMD_RESULT=$(TEST_STANDARD_INPUT)
      sleep 2
      OPERATION="TEST STANDARD INPUT"
      ;;
    9)
      OPERATION="TEST PED KEYS"
      echo "$BRed"
      echo "Are you sure ? Executing this will STOP all MRV applications : Type [yes/y or no/n] $Color_Off"
      read TEST_PED_KEYS_OPTION
      if [ "$TEST_PED_KEYS_OPTION" = 'yes' ] || [ "$TEST_PED_KEYS_OPTION" = 'y' ]; then
        ACTION "Testing PED KEYPAD"
        CMD_RESULT=$(TEST_PED_KEYS)
        RESET_PERIPHERAL "ped"
        sleep 2
      else
        CMD_RESULT="Skipped testing PED Keypad"
        echo "Skipping testing PED keypad..."
        sleep 2
      fi
      ;;
    10)
      OPERATION="TEST SIGNATURE ON PED"
      echo "$BRed"
      echo "Are you sure ? Executing this will STOP all MRV applications : Type [yes/y or no/n] $Color_Off"
      read TEST_SIGNATURE_ON_PED_OPTION
      if [ "$TEST_SIGNATURE_ON_PED_OPTION" = 'yes' ] || [ "$TEST_SIGNATURE_ON_PED_OPTION" = 'y' ]; then
        ACTION "Testing Signature on PED"
        CMD_RESULT=$(TEST_SIGNATURE_ON_PED)
        RESET_PERIPHERAL "ped"
        sleep 2
      else
        CMD_RESULT="Skipped Testing Signature on PED"
        echo "Skipping Testing Signature on PED..."
        sleep 2
      fi
      ;;
    11)
      OPERATION="TEST CARD CAPTURE"
      echo "$BRed"
      echo "Are you sure ? Executing this will STOP all MRV applications : Type [yes/y or no/n] $Color_Off"
      read TEST_CARD_CAPTURE_OPTION
      if [ "$TEST_CARD_CAPTURE_OPTION" = 'yes' ] || [ "$TEST_CARD_CAPTURE_OPTION" = 'y' ]; then
        ACTION "Testing Card Capture"
        CMD_RESULT=$(TEST_CARD_CAPTURE)
        RESET_PERIPHERAL "ped"
        sleep 2
      else
        CMD_RESULT="Skipped Testing Card Capture"
        echo "Skipping Testing Card Capture..."
        sleep 2
      fi
      ;;
    12)
      echo "$BRed"
      echo "Are you sure ? This will RESET PED : Type [yes/y or no/n] $Color_Off"
      read RESET_PED_OPTION
      OPERATION="RESET PED"
      if [ $RESET_PED_OPTION = 'yes' ] || [ $RESET_PED_OPTION = 'y' ]; then
        ACTION "Resetting PED"
        CMD_RESULT=$(RESET_PERIPHERAL "ped")
        sleep 2
      else
        CMD_RESULT="Skipped PED Reset"
        echo "Skipping PED Reset..."
        sleep 2
      fi
      ;;
    13)
      echo "$BRed"
      echo "Are you sure ? This will RESET CASH-RECYCLER : Type [yes/y or no/n] $Color_Off"
      read RESTART_CR_OPTION
      OPERATION="RESET CASH_RECYCLER"
      if [ $RESTART_CR_OPTION = 'yes' ] || [ $RESTART_CR_OPTION = 'y' ]; then
        ACTION "Resetting Cash Recycler"
        CMD_RESULT=$(RESET_RECYCLER)
        sleep 2
      else
        CMD_RESULT="Skipped Cash-Recycler Reset"
        echo "Skipping Cash-Recycler Reset..."
        sleep 2
      fi
      ;;
    14)
      echo "$BRed"
      echo "Are you sure ? This will RESET All PERIPHERALS : Type [yes/y or no/n] $Color_Off"
      read RESTART_ALL_PERIPHERALS_OPTION
      OPERATION="RESET ALL PERIPHERALS"
      if [ $RESTART_ALL_PERIPHERALS_OPTION = 'yes' ] || [ $RESTART_ALL_PERIPHERALS_OPTION = 'y' ]; then
        ACTION "Resetting All Peripherals"
        CMD_RESULT=$(RESET_ALL_PERIPHERALS)
        sleep 2
      else
        CMD_RESULT="Skipped All Peripherals Reset"
        echo "skipping peripherals Reset..."
        sleep 2
      fi
      ;;
    15)
      echo "$BRed"
      echo "Are you sure ? This will restart the TachyonX : Type [yes/y or no/n] $Color_Off"
      read RESTART_TACHYONX
      OPERATION="RESET TACHYONX"
      if [ $RESTART_TACHYONX = 'yes' ] || [ $RESTART_TACHYONX = 'y' ]; then
        ACTION "Restarting TachyonX"
        CMD_RESULT=$(RESTART_TACHYONX)
        #CMD_RESULT="UI has been reset"
        sleep 2
      else
        CMD_RESULT="Skipped UI Reset"
        echo "Skipping UI restart..."
      fi
      ;;
    16)
      echo "$BRed"
      echo "Are you sure ? This will end this session and Reboots Touchpoint : Type [yes/y or no/n] $Color_Off"
      read REBOOT_OPTION
      OPERATION="REBOOT TOUCHPOINT"
      if [ $REBOOT_OPTION = 'yes' ] || [ $REBOOT_OPTION = 'y' ]; then
        ACTION "Triggering TOUCHPOINT Reboot"
        REBOOT_REGISTER
      else
        echo "skipping reboot..."
        CMD_RESULT="Skipped reboot"
      fi
      ;;
    17)
      OPERATION="TEST CHECK SCAN"
      echo "$BRed"
        echo "Are you sure ? Executing this will STOP all MRV applications : Type [yes/y or no/n] $Color_Off"
        read TEST_CHECK_SCAN_OPTION
        if [ "$TEST_CHECK_SCAN_OPTION" = 'yes' ] || [ "$TEST_CHECK_SCAN_OPTION" = 'y' ]; then
          ACTION "Testing Check Scan"
  	  echo "\nInsert the check"
	  CMD_RESULT=$(TEST_CHECK_SCAN)
        else
          CMD_RESULT="Skipped Testing Check Scan"
          echo "Skipping Testing Check Scan..."
        fi
      ;;
    18)
      OPERATION="TEST CHECK FRANK"
      echo "$BRed"
      echo "Are you sure ? Executing this will STOP all MRV applications : Type [yes/y or no/n] $Color_Off"
      read TEST_CHECK_FRANK_OPTION
      if [ "$TEST_CHECK_FRANK_OPTION" = 'yes' ] || [ "$TEST_CHECK_FRANK_OPTION" = 'y' ]; then
        ACTION "Testing Check Frank"
  	echo " Insert check like sheet to test frank"
        CMD_RESULT=$(TEST_CHECK_FRANK)
        #RESET_PERIPHERAL "check-reader"
      else
        CMD_RESULT="Skipped Testing Check Frank"
        echo "Skipping Testing Check Frank..."
      fi
      ;;
    19)
      OPERATION="RESOLVE APP NOT SUPPORTED"
      echo "$BRed"
      echo "Are you sure ? Executing this will STOP all MRV applications : Type [yes/y or no/n] $Color_Off"
      read RESOLVE_APP_NOT_SUPPORTED_OPTION
      
      if [ "$RESOLVE_APP_NOT_SUPPORTED_OPTION" = 'yes' ] || [ "$RESOLVE_APP_NOT_SUPPORTED_OPTION" = 'y' ]; then
        ACTION "Resolving application not supported"
        CMD_RESULT=$(RESOLVE_APP_NOT_SUPPORTED)
      else
        CMD_RESULT="Skipped resolving application not supported"
      fi
      sleep 2
      ;;
    20)
      OPERATION="UPDATE PACKAGES AND CONFIGS ON VERIFONE M400/MX925"
      echo "$BRed"
      echo "Are you sure ? Executing this will STOP all MRV applications and REBOOT the ped: Type [yes/y or no/n] $Color_Off"
      read CONFIGURE_VERIFONE_PED_OPTION
      
      if [ "$CONFIGURE_VERIFONE_PED_OPTION" = 'yes' ] || [ "$CONFIGURE_VERIFONE_PED_OPTION" = 'y' ]; then
        ACTION "Updating ped configs"
        CMD_RESULT=$(UPDATE_PACKAGES_CONFIGS_FOR_VERIFONE_PED)
      else
        CMD_RESULT="Skipped updating ped configs"
      fi
      sleep 2
      ;;
   *)
    OPERATION="INVALID"
    CMD_RESULT="$BRed Invalid Option Selected"
    ;;
    esac
  done
}

BANNER
MAIN
clear
