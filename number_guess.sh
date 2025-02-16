#!/bin/bash

PSQL="psql --username=freecodecamp --dbname=number_guess -t --no-align -c"

echo "Enter your username:"
read USERNAME

USER_DATA=$($PSQL "SELECT user_id, games_played, best_game FROM users WHERE username='$USERNAME'")

if [[ -z $USER_DATA ]]; then
  INSERT_USER=$($PSQL "INSERT INTO users(username, games_played, best_game) VALUES('$USERNAME', 0, NULL)")
  echo "Welcome, $USERNAME! It looks like this is your first time here."
  USER_ID=$($PSQL "SELECT user_id FROM users WHERE username='$USERNAME'")
  GAMES_PLAYED=0
  BEST_GAME=NULL
else
  IFS="|" read USER_ID GAMES_PLAYED BEST_GAME <<< "$USER_DATA"
  echo "Welcome back, $USERNAME! You have played $GAMES_PLAYED games, and your best game took $BEST_GAME guesses."
fi

NUM_GEN=$((1 + RANDOM % 1000))
GUESS_COUNT=0

echo "Guess the secret number between 1 and 1000:"

while read GUESS; do
  if [[ ! $GUESS =~ ^[0-9]+$ ]]; then
    echo "That is not an integer, guess again:"
    continue
  fi

  ((GUESS_COUNT++))

  if [[ $GUESS -eq $NUM_GEN ]]; then
    echo "You guessed it in $GUESS_COUNT tries. The secret number was $NUM_GEN. Nice job!"
    break
  elif [[ $GUESS -gt $NUM_GEN ]]; then
    echo "It's lower than that, guess again:"
  else
    echo "It's higher than that, guess again:"
  fi
done

NEW_GAMES_PLAYED=$((GAMES_PLAYED + 1))

if [[ $BEST_GAME == "NULL" || $GUESS_COUNT -lt $BEST_GAME ]]; then
  NEW_BEST_GAME=$GUESS_COUNT
else
  NEW_BEST_GAME=$BEST_GAME
fi

UPDATE_STATS=$($PSQL "UPDATE users SET games_played=$NEW_GAMES_PLAYED, best_game=$NEW_BEST_GAME WHERE user_id=$USER_ID")