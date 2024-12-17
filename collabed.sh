#!/usr/bin/env sh

# TODO set it up to read any positional argumants to the command
# TODO write a --help flag

source config.sh
source helpers.sh

user=$default_user_id
read -p "what User ID? " user
check=${#user}
if [ $check -lt 1 ]; then
    user="$default_user_id"
fi

item=$default_item_id
read -p "what Item ID? " item
check=${#item}
if [ $check -lt 1 ]; then
    item="$default_item_id"
fi

# call check collab function
check_collaboration "$item" "$user" "$collabtable"
# Capture the exit status of the fn we just ran
status=$?

if [[ $status -eq 0 ]]; then
    echo "Direct collaboration found. Exiting script."
    exit 0  # End the entire script with success
fi
#okay if we didn't find a direct collab on the item itself
#we'll check any parent folders.

#running this query to get the path of the parent folders
query=$(bq query --nouse_legacy_sql --format=prettyjson\
    'SELECT
       path_ids
     FROM
        `'$foldertable'`
     WHERE
         folder_id='$item)

path_ids=$(echo $query | jq -r '.[].path_ids')

# Remove the leading and trailing slashes
path_ids="${path_ids#/}"
path_ids="${path_ids%/}"

echo "Here's the path of the parent folders, if any:"
echo "$path_ids"

# Use IFS (Internal Field Separator) to split the string by '/'
# (this could very possibly be a bad idea, idk)
IFS='/' read -r -a arr <<< "$path_ids"

# Loop through each element in the array
for num in "${arr[@]}"; do
    check_collaboration "$num" "$user" "$collabtable"
done
