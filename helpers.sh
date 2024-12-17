#!/usr/bin/env sh


# Function to check collaboration
check_collaboration() {
    local item=$1
    local user=$2
    local collabtable=$3

    # Run the query
query=$(bq query --nouse_legacy_sql --format=prettyjson\
    'SELECT
        user_id,
        item_type
     FROM
        `'$collabtable'`
     WHERE
         item_id='$item)

    # Use jq to pluck item_type from the first result
    item_type=$(echo "$query" | jq -r '.[0].item_type')
    #item_type="swingobingo"

    # Extract user IDs from the query result
    user_ids=$(echo "$query" | jq -r '.[].user_id')

    # Loop through user IDs and check for match
    for user_id in $user_ids; do
        # If the user matches, set the flag and exit loop
        if [ "$user_id" -eq "$user" ]; then
            echo "okay I see that $user is collaborated on $item_type ID $item"
            return 0  # Return success
        fi
    done
    # If no match found
    echo "no collab for User ID $user on $item_type ID $item."
    return 1  # Return failure
}
