#!/bin/sh

USER_NAME=${LOCAL_USER_NAME:-'www-data'}
GROUP_NAME=${LOCAL_GROUP_NAME:-'www-data'}

# This is a wrapper so that wp-cli can run as the local user or as www-data user (Alpine default)
su-exec $USER_NAME:$GROUP_NAME /usr/local/bin/wp-cli.phar $*
