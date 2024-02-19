#!/bin/bash
PSQL="psql --username=freecodecamp --dbname=number_guess -t --no-align -c"

# Ask for a username
echo "Enter your username:"
read USERNAME

# check if user is in db
USER_RESULT="$( $PSQL "SELECT games_played, best_game FROM users WHERE username='$USERNAME'" )"

# if not in db
if [[ -z $USER_RESULT ]]; then
  echo "Welcome, $USERNAME! It looks like this is your first time here."
  GAMES_PLAYED=0
  BEST_GAME=""
  # Add user, silently
  $PSQL "INSERT INTO users(username) VALUES ('$USERNAME')" > /dev/null
else
  GAMES_PLAYED="$( echo $USER_RESULT | cut -f1 -d\| )"
  BEST_GAME="$( echo $USER_RESULT | cut -f2 -d\| )"

  echo "Welcome back, $USERNAME! You have played $GAMES_PLAYED games, and your best game took $BEST_GAME guesses."
fi

# Generate random number between 1-1000
# The +1 is so that we don't have 0
RAND_NUM=$(( 1 + $RANDOM % 1000 ))

echo "Guess the secret number between 1 and 1000:"
read GUESS


GUESSES=0
while [[ $GUESS != $RAND_NUM ]]; do
  GUESSES=$(($GUESSES+1))
  # We need integers, nothing more
  if ! [[ $GUESS =~ ^[0-9]+$ ]]; then
    echo "That is not an integer, guess again:"
  elif [[ $GUESS -lt $RAND_NUM ]]; then
    echo "It's higher than that, guess again:"
  elif [[ $GUESS -gt $RAND_NUM ]]; then
    echo "It's lower than that, guess again:"
  fi
  read GUESS
done
# A correct guess is still a guess
GUESSES=$(($GUESSES+1))
GAMES_PLAYED=$(($GAMES_PLAYED+1))

# Update best game
if [[ -z $BEST_GAME || $GUESSES -lt $BEST_GAME ]]; then
  BEST_GAME=$GUESSES
fi
$PSQL "UPDATE users SET games_played=$GAMES_PLAYED, best_game=$BEST_GAME WHERE username='$USERNAME'" > /dev/null

echo "You guessed it in $GUESSES tries. The secret number was $RAND_NUM. Nice job!"
