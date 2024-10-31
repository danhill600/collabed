#!/usr/bin/env sh

#we'll start with a naive implementation that just checks the defined item ID for the defined UID
#after that's up and going we'll start making calls to see if the defined Item ID has any parents
#and check those too.


source config.sh

#echo $mytable

read -p "what Item ID? " item

myvariable=$(bq query --nouse_legacy_sql --format=prettyjson\
    'SELECT
        user_id
     FROM
        `'$mytable'`
     WHERE
         item_id='$item)

echo $myvariable | jq -s
