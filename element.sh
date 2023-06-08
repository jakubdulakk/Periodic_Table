#!/bin/bash

# create PSQL variable to query database
PSQL="psql -X --username=freecodecamp --dbname=periodic_table --tuples-only -c"

# Check if any arguments are provided
if [[ $# -eq 0 ]]; then
  echo "Please provide an element as an argument."
else
  INPUT=$1

  # Determine the maximum atomic number available in the elements table
  MAX_ATOMIC_NUMBER=$($PSQL "SELECT MAX(atomic_number) FROM elements")

  # Check if input is a valid number
  if [[ $INPUT =~ ^[0-9]+$ ]]; then
    # Convert input to integer
    NUMBER=$((INPUT))

    # Check if input is within the valid range
    if ((NUMBER > MAX_ATOMIC_NUMBER)); then
      echo "I could not find that element in the database."
      exit
    fi

    SYMBOL=$($PSQL "SELECT symbol FROM elements WHERE atomic_number = '$NUMBER'")
    NAME=$($PSQL "SELECT name FROM elements WHERE atomic_number = '$NUMBER'")

  else
    # Check if input is a symbol
    SYMBOL=$INPUT
    NUMBER=$($PSQL "SELECT atomic_number FROM elements WHERE symbol = '$SYMBOL'")
    
    # Check if symbol exists in the periodic table
    if [[ -z $NUMBER ]]; then
      # Check if input is a name
      NAME=$INPUT
      NUMBER=$($PSQL "SELECT atomic_number FROM elements WHERE name = '$NAME'")
      
      # Check if name exists in the periodic table
      if [[ -z $NUMBER ]]; then
        echo "I could not find that element in the database."
        exit
      else
        SYMBOL=$($PSQL "SELECT symbol FROM elements WHERE atomic_number = '$NUMBER'")
      fi
    else
      NAME=$($PSQL "SELECT name FROM elements WHERE symbol = '$SYMBOL'")
    fi
  fi

  # Retrieve element information
  ATOMIC_MASS=$($PSQL "SELECT atomic_mass FROM properties WHERE atomic_number = '$NUMBER'")
  MELTING_POINT=$($PSQL "SELECT melting_point_celsius FROM properties WHERE atomic_number = '$NUMBER'")
  BOILING_POINT=$($PSQL "SELECT boiling_point_celsius FROM properties WHERE atomic_number = '$NUMBER'")

  # Retrieve and display the metal type based on the atomic number
  TYPE=$($PSQL "SELECT type FROM types WHERE type_id IN (SELECT type_id FROM properties WHERE atomic_number = '$NUMBER')")

  # Trim leading spaces from the retrieved values
  SYMBOL=$(echo "$SYMBOL" | xargs)
  NUMBER=$(echo "$NUMBER" | xargs)
  NAME=$(echo "$NAME" | xargs)
  ATOMIC_MASS=$(echo "$ATOMIC_MASS" | xargs)
  MELTING_POINT=$(echo "$MELTING_POINT" | xargs)
  BOILING_POINT=$(echo "$BOILING_POINT" | xargs)
  TYPE=$(echo "$TYPE" | xargs)

  echo "The element with atomic number $NUMBER is $NAME ($SYMBOL). It's a $TYPE, with a mass of $ATOMIC_MASS amu. $NAME has a melting point of $MELTING_POINT celsius and a boiling point of $BOILING_POINT celsius."
fi
