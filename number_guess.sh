#!/bin/bash

PSQL="psql --username=freecodecamp --dbname=number_guess -t --no-align -c"

#echo $($PSQL "TRUNCATE TABLE players RESTART IDENTITY")

RAND_NUMBER=$(( ( RANDOM % 1000 )  + 1 ))
#echo $RAND_NUMBER

CORRECT_GUESS=0
GUESS_COUNT=1
#echo $GUESS_COUNT

echo -e "Enter your username:"
read USERNAME


CHECK_USERNAME=$($PSQL "SELECT * FROM players WHERE username = '$USERNAME'")
echo "$CHECK_USERNAME" | while IFS="|" read NAME PLAYER_ID NUMBER_PLAYED BEST_GUESS
do
  if [[ -z $CHECK_USERNAME ]] 
  then
    INSERT_CUSTOMER_RESULT=$($PSQL "INSERT INTO players(username, number_played) VALUES('$USERNAME', 0)")
    echo "Welcome, $USERNAME! It looks like this is your first time here."
  else 
    PLAYER_DATA=$($PSQL "SELECT * FROM players WHERE username = '$USERNAME'")
    #echo $PLAYER_DATA| while IFS="|" read NAME
    echo "Welcome back, $USERNAME! You have played $NUMBER_PLAYED games, and your best game took $BEST_GUESS guesses."
  fi
done


echo -e "Guess the secret number between 1 and 1000:"
#CORRECT_GUESS=$(( $CORRECT_GUESS + 1 ))
while [ $CORRECT_GUESS -le 0 ]
do
  read PLAYER_GUESS
  if ! [[ $PLAYER_GUESS =~ ^[0-9]+$ ]]
  then
    echo That is not an integer, guess again:
  else
    if [ $PLAYER_GUESS == $RAND_NUMBER ]
    then
     CORRECT_GUESS=$(( $CORRECT_GUESS + 1 ))
   else
     if [[ $PLAYER_GUESS < $RAND_NUMBER ]]
     then
       GUESS_COUNT=$(( $GUESS_COUNT + 1 ))
       echo "It's higher than that, guess again:"
     else
       if [[ $PLAYER_GUESS > $RAND_NUMBER ]]
       then
         GUESS_COUNT=$(( $GUESS_COUNT + 1 ))
         echo "It's lower than that, guess again:"      
       fi
     fi
   fi
  fi

done

#echo Number of guesses: $GUESS_COUNT
CHECK_BEST_GUESS=$($PSQL "SELECT best_guess FROM players WHERE username = '$USERNAME'")
CHECK_NUMBER_PLAYED=$($PSQL "SELECT number_played FROM players WHERE username = '$USERNAME'")
#echo Best guess from db: $CHECK_BEST_GUESS
#echo Number played from db: $CHECK_NUMBER_PLAYED

CHECK_NUMBER_PLAYED=$(( $CHECK_NUMBER_PLAYED + 1 ))

if [[ -z $CHECK_BEST_GUESS ]]
then
  echo $($PSQL "UPDATE players SET number_played=$CHECK_NUMBER_PLAYED, best_guess=$GUESS_COUNT WHERE username='$USERNAME'")
else
  if [[ $GUESS_COUNT < $CHECK_BEST_GUESS ]]
  then
    echo $($PSQL "UPDATE players SET number_played=$CHECK_NUMBER_PLAYED, best_guess=$GUESS_COUNT WHERE username='$USERNAME'")
  else
    echo $($PSQL "UPDATE players SET number_played=$CHECK_NUMBER_PLAYED WHERE username='$USERNAME'")
  fi
fi

echo -e "You guessed it in $GUESS_COUNT tries. The secret number was $RAND_NUMBER. Nice job!"

#$PLAYER_GUESS=12
#echo $PLAYER_GUESS
