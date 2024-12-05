#!/usr/bin/env sh

#we'll start with a naive implementation that just checks the defined item ID for the defined UID
#after that's up and going we'll start making calls to see if the defined Item ID has any parents
#and check those too.

source config.sh

#probbably break this into a separate helperfunctions.sh so somebody has a chance of being able
#to read this.
#
# Function to check collaboration
check_collaboration() {
    local item=$1
    local user=$2

    # Run the query
    query=$(bq query --nouse_legacy_sql --format=prettyjson \
        "SELECT user_id, item_type FROM \`$collabtable\` WHERE item_id='$item'")

    # Extract user IDs from the query result
    user_ids=$(echo "$query" | jq -r '.[].user_id')

    # Loop through user IDs and check for match
    for user_id in $user_ids; do
        # If the user matches, set the flag and exit loop
        if [ "$user_id" -eq "$user" ]; then
            echo "okay I see that $user is collaborated on $item"
            iscollabed=yes
            return 0  # Return success
        fi
    done

    # If no match found
    return 1  # Return failure
}

# Example usage



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

#query=$(bq query --nouse_legacy_sql --format=prettyjson\
#    'SELECT
#        user_id,
#        item_type
#     FROM
#        `'$collabtable'`
#     WHERE
#         item_id='$item)
#
#user_ids=$(echo $query | jq -r '.[].user_id')
#
#for user_id in $user_ids; do
#  #echo "one user collaborated on the file is: " $user_id
#    if [ "$user_id" -eq "$user" ]; then
#        echo "okay I see that $user is collaborated on $item"
#        iscollabed=yes
#        break
#    fi
#done
#
# Call the function
check_collaboration "$item" "$user"

# Check if collaboration was found
if [ "$iscollabed" == "yes" ]; then
    echo "User is collaborated."
else
    echo "No collaboration found."
fi

if [[ "$iscollabed" != "yes" ]]; then
   echo "okay the user is not directly collabed on the item,"
   echo "although it's possible it could still have access via"
   echo "either waterfalling or group membership"
   echo "let's check for parent folders..."
fi

#check if the item is in the folders table, if it is, great, we can grab the path
#if not, okay great, we'll check the files table to get its folder.


query=$(bq query --nouse_legacy_sql --format=prettyjson\
    'SELECT
       path_ids
     FROM
        `'$foldertable'`
     WHERE
         folder_id='$item)

#echo $query
path_ids=$(echo $query | jq -r '.[].path_ids')

# Remove the leading and trailing slashes
path_ids="${path_ids#/}"
path_ids="${path_ids%/}"
echo "$path_ids"


# Use IFS (Internal Field Separator) to split the string by '/'
IFS='/' read -r -a arr <<< "$path_ids"

# Loop through each element in the array
for num in "${arr[@]}"; do
    echo "Processing number: $num"

    folder_id=$num

done
