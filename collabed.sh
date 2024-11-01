#!/usr/bin/env sh

#we'll start with a naive implementation that just checks the defined item ID for the defined UID
#after that's up and going we'll start making calls to see if the defined Item ID has any parents
#and check those too.

source config.sh

# TODO set it up to read any positional argumants to the command
# set default variables for item and user

user=$default_user_id
read -p "what User ID? " user
check=${#user}
if [ $check -lt 1 ]; then
    user="$default_user_id"
#    echo "okay can just use the default user ID of $user"
fi

item=$default_item_id
read -p "what Item ID? " item
check=${#item}

if [ $check -lt 1 ]; then
    item="$default_item_id"
fi

query=$(bq query --nouse_legacy_sql --format=prettyjson\
    'SELECT
        user_id
     FROM
        `'$mytable'`
     WHERE
         item_id='$item)

echo $query | jq -s
