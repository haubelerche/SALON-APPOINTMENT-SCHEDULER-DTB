#! /bin/bash
PSQL="psql -X --username=freecodecamp --dbname=salon --tuples-only -c"

echo -e "\n~~~~~ Heaven's Salon ~~~~~\n"

MAIN_MENU() {
  if [[ $1 ]]
  then
    echo -e "\n$1"
  fi

  # show list of services
  echo -e "Here are the services we offer:"
  SERVICES=$($PSQL "SELECT service_id, name FROM services ORDER BY service_id")
  echo "$SERVICES" | while read SERVICE_ID BAR SERVICE_NAME
  do
    echo "$SERVICE_ID) $SERVICE_NAME"
  done

  # Prompt service selection
  echo -e "\nWhich service would you like to request?"
  read SERVICE_ID_SELECTED

  # check srvice selection
  if [[ ! $SERVICE_ID_SELECTED =~ ^[0-9]+$ ]] || [[ -z $($PSQL "SELECT service_id FROM services WHERE service_id = $SERVICE_ID_SELECTED") ]]
  then
    MAIN_MENU "We don't have that kind of service. Please retry or leave ;)"
  else
    SERVICES
  fi
}

SERVICES() {
  # Get customer p number
  echo -e "\nWhat's your phone number?"
  read CUSTOMER_PHONE

  # Check if customer exists
  CUSTOMER_NAME=$($PSQL "SELECT name FROM customers WHERE phone = '$CUSTOMER_PHONE'")
  if [[ -z $CUSTOMER_NAME ]]
  then
    
    echo -e "\nWhat's your name?"
    read CUSTOMER_NAME

    # Insert new customer
    INSERT_CUSTOMER_RESULT=$($PSQL "INSERT INTO customers(name, phone) VALUES('$CUSTOMER_NAME', '$CUSTOMER_PHONE')")
  fi

  # Get customer_id
  CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone = '$CUSTOMER_PHONE'")

  # Get service time
  echo -e "\nWhat time would you like to schedule your appointment?"
  read SERVICE_TIME

  # Insert appointment
  INSERT_APPOINTMENT_RESULT=$($PSQL "INSERT INTO appointments(customer_id, service_id, time) VALUES($CUSTOMER_ID, $SERVICE_ID_SELECTED, '$SERVICE_TIME')")

  # Confirmation message
  if [[ $INSERT_APPOINTMENT_RESULT == "INSERT 0 1" ]]
  then
    SERVICE_NAME=$($PSQL "SELECT name FROM services WHERE service_id = $SERVICE_ID_SELECTED")
    echo -e "\nYesss sirrrr, I have put you down for a $(echo $SERVICE_NAME | sed -r 's/^ *| *$//g') at $SERVICE_TIME, $CUSTOMER_NAME." 
  else
    echo -e "\nBruhhhhhhhhh, there was an error scheduling your appointment. Please retry or say goodbye ;)"
  fi
}

MAIN_MENU
