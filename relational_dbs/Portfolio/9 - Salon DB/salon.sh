#!/bin/bash

# Get info from sql
PSQL='psql --username=freecodecamp --dbname=salon --no-align --tuples-only -c'
# We're going to call this a lot
SALON_SERVICES=($($PSQL "SELECT name FROM services"))
# Always a good idea to get a count 
NUM_SERVICES=$( echo ${SALON_SERVICES[*]} | wc -w )
SALON_NAME="Drive-Thru Salon"


function enumerate_services () {
  # Add all services from DB to the console for selection
  I=1
  # Can't quite figure out how to split strings yet
  echo "$($PSQL "SELECT name FROM services")" | while read SERVICE
  do
  echo "$I) $SERVICE"
  I=$((I+1))
  done
}

function input_check () {
  # check to see if input is not one of our numbers
  while true
  do
    read SERVICE_ID_SELECTED
    if [[ $SERVICE_ID_SELECTED -gt $NUM_SERVICES  || $SERVICE_ID_SELECTED -lt 1 ]]
    then
      echo -e "\nI could not find that service. What would you like today?"
      enumerate_services
    else
      # This is likely bad form in some way
      #echo $SERVICE_ID_SELECTED
      # Defs bad form.
      return $(( SERVICE_ID_SELECTED ))
    fi
  done
}

echo -e "\n~~~~ $SALON_NAME ~~~~"
echo -e "\nWelcome to $SALON_NAME, how can I help you?\n"

# get services and check input
enumerate_services
input_check 
SERVICE_IDX=$?
SERVICE_NAME=${SALON_SERVICES[$(( $SERVICE_IDX - 1 ))]}
SERVICE_ID=$( $PSQL "SELECT service_id FROM services WHERE name='$SERVICE_NAME'" )

echo -e "\nWhat's your phone number?"
read CUSTOMER_PHONE

# Get name from phone number
CUSTOMER_NAME=$( $PSQL "SELECT name FROM customers WHERE phone='$CUSTOMER_PHONE'" )

# Customer is unknown
if [[ -z $CUSTOMER_NAME ]]
then
  echo -e "\nI don't have a record for that phone number, what's your name?"
  read CUSTOMER_NAME
  # To make this call silent
  $( $PSQL "INSERT INTO customers(phone, name) VALUES ('$CUSTOMER_PHONE', '$CUSTOMER_NAME')" )
fi

CUST_ID=$( $PSQL "SELECT customer_id FROM customers WHERE phone='$CUSTOMER_PHONE'" )

echo -e "\nWhat time would you like your cut, $CUSTOMER_NAME?"
read SERVICE_TIME
# Also to make this call silent.
APPT_RESULT=$( $PSQL "INSERT INTO appointments(customer_id, service_id, time) VALUES ($CUST_ID, $SERVICE_ID, '$SERVICE_TIME')" )

echo -e "\nI have put you down for a $SERVICE_NAME at $SERVICE_TIME, $CUSTOMER_NAME."