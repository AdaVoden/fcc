#! /bin/bash

if [[ $1 == "test" ]]
then
  PSQL="psql --username=postgres --dbname=worldcuptest -t --no-align -c"
else
  PSQL="psql --username=freecodecamp --dbname=worldcup -t --no-align -c"
fi

# Do not change code above this line. Use the PSQL variable above to query your database.

# Can't get this to work, don't want to burn too much time on it
# function ADD_TEAM () {
#   # Function to ensure teams are added properly
#   TEAM_ID=$($PSQL "SELECT team_id FROM teams WHERE name='$1';")
#   if [[ -z $TEAM_ID ]]
#   then
#     INSERT_TEAM_RESULT=$( $PSQL "INSERT INTO teams(name) VALUES ('$1');")
#     if [[ $INSERT_TEAM_RESULT == "INSERT 0 1" ]]
#     then
#       echo Inserted team: $1
#     fi
#     # Team now looks weird to look at.
#     # Get the ID to return
#     TEAM_ID=$( $PSQL "SELECT team_id FROM teams WHERE name='$1';" )
#   fi
#   # Echo so that the team_id goes to std output
#   echo $TEAM_ID
# }
# Clear previously entered information, to ensure we don't have to
# If we screw up somehow
echo Truncating all tables... $( $PSQL "TRUNCATE teams, games" )

cat games.csv | while IFS="," read YEAR ROUND WINNER OPPONENT WINNER_GOALS OPPONENT_GOALS
do
  # Make sure we don't include the initial line
  
  if [[ $YEAR != "year" ]]
  then
    # Add winner team
    WINNER_ID=$( $PSQL "SELECT team_id FROM teams WHERE name='$WINNER'" )
    # Team is not added, so add
    if [[ -z $WINNER_ID ]]
    then
      # Insert missing team
      INSERT_TEAM_RESULT=$( $PSQL "INSERT INTO teams(name) VALUES ('$WINNER')" )
      if [[ $INSERT_TEAM_RESULT == "INSERT 0 1" ]]
      then
        echo Inserted team: $WINNER
      fi
      WINNER_ID=$( $PSQL "SELECT team_id FROM teams WHERE name='$WINNER'" )
    fi
    # Add opponent team
    OPPONENT_ID=$( $PSQL "SELECT team_id FROM teams WHERE name='$OPPONENT'" )
    # Team is not added, so add
    if [[ -z $OPPONENT_ID ]]
    then
      # Insert missing team
      INSERT_TEAM_RESULT=$( $PSQL "INSERT INTO teams(name) VALUES ('$OPPONENT')" )

      if [[ $INSERT_TEAM_RESULT == "INSERT 0 1" ]]
      then
        echo Inserted team: $OPPONENT
      fi
      OPPONENT_ID=$( $PSQL "SELECT team_id FROM teams WHERE name='$OPPONENT'" )
    fi

    # Add in the games
    GAME_ID=$( $PSQL "SELECT game_id FROM games WHERE year='$YEAR' AND round='$ROUND' AND winner_id=$WINNER_ID" )
    # Game is not added, so add
    if [[ -z $GAME_ID ]]
    then
      INSERT_GAME_RESULT=$( $PSQL "INSERT INTO games(year, round, winner_id, opponent_id, winner_goals, opponent_goals) VALUES ($YEAR, '$ROUND', $WINNER_ID, $OPPONENT_ID, $WINNER_GOALS, $OPPONENT_GOALS)" )
      if [[ $INSERT_GAME_RESULT == "INSERT 0 1" ]]
      then
        echo Inserted game: Year $YEAR, $WINNER vs $OPPONENT
      fi
    fi
  fi
done