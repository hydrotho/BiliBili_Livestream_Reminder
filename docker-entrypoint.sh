#!/usr/bin/env bash

# Exit immediately if a command exits with a non-zero status
set -e

# Set the user ID to 1000 or the value of USER_ID environment variable if it's set
ID_USER=${USER_ID:-1000}

# Set the group ID to 1000 or the value of GROUP_ID environment variable if it's set
ID_GROUP=${GROUP_ID:-1000}

# Set the username and groupname to 'static'
NAME=static

# If the current user is root
if [ "$(id -u)" = "0" ]; then
    # Check if the group exists and if not add it
    if ! getent group $NAME > /dev/null; then
        groupadd --gid "$ID_GROUP" "$NAME"
    fi

    # Check if the user exists and if not add it
    if ! getent passwd $NAME > /dev/null; then
        useradd --uid "$ID_USER" --gid "$ID_GROUP" --create-home --shell /bin/bash "$NAME"
    fi

    # Run the current script as the new user
    exec gosu "$NAME" "$0" "$@"
fi

# Execute the command specified by the arguments
exec "$@"
