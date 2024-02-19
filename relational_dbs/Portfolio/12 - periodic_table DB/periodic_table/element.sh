#!/bin/bash

PSQL="psql --username=freecodecamp --dbname=periodic_table -t --no-align -c"
# Check if argument hasn't been given
if [[ -z $1 ]]
then
  echo "Please provide an element as an argument."
else

  # Create query for element
  QUERY="SELECT atomic_number, name, symbol, type, atomic_mass, melting_point_celsius, boiling_point_celsius FROM elements LEFT JOIN properties USING(atomic_number) LEFT JOIN types USING(type_id)"

  # Check if argument is a number
  if [[ $1 =~ ^[0-9]+$ ]]; then
    #Adjust query based on input
    QUERY="$QUERY WHERE atomic_number=$1"
  else
    #Adjust query based on input
    QUERY="$QUERY WHERE name='$1' OR symbol='$1'"
  fi
  # Get element from db
  ELEMENT="$($PSQL "$QUERY" )"

  # Check if element is in DB
  if [[ -z $ELEMENT ]]; then
    echo "I could not find that element in the database."
  else
    #Split result into parts
    ATOMIC_NUMBER="$( echo $ELEMENT | cut -f1 -d\| )"
    NAME="$( echo $ELEMENT | cut -f2 -d\| )"
    SYMBOL="$( echo $ELEMENT | cut -f3 -d\| )"
    TYPE="$( echo $ELEMENT | cut -f4 -d\| )"
    ATOMIC_MASS="$( echo $ELEMENT | cut -f5 -d\| )"
    MELTING_POINT="$( echo $ELEMENT | cut -f6 -d\| )"
    BOILING_POINT="$( echo $ELEMENT | cut -f7 -d\| )"

    echo "The element with atomic number $ATOMIC_NUMBER is $NAME ($SYMBOL). It's a $TYPE, with a mass of $ATOMIC_MASS amu. $NAME has a melting point of $MELTING_POINT celsius and a boiling point of $BOILING_POINT celsius."
  fi
fi
