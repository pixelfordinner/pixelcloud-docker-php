#!/bin/bash

# This script will use LOCAL_USER_NAME and LOCAL_USER_ID
# as well as LOCAL_GROUP_NAME and LOCAL_GROUP_ID from env
# and create the user and group if they don't exist
# and then use them to start php-fpm with.
# If absent, will use php-fpm's alpine default config: www-data:www-data
# Not setting any env var will result in default image behaviour.

USER_NAME=${LOCAL_USER_NAME:-'www-data'}
GROUP_NAME=${LOCAL_GROUP_NAME:-'www-data'}
UMASK=${LOCAL_UMASK:-'002'}
PHP_CONF=/usr/local/etc/php-fpm.d/www.conf

echo "Starting php-fpm as ${USER_NAME}:${GROUP_NAME}"

if [ $(grep -c "^${GROUP_NAME}:" /etc/group) == 0 ]; then
  echo "Creating group $GROUP_NAME"
  addgroup --system --gid $LOCAL_GROUP_ID $GROUP_NAME
else
  echo "Group $GROUP_NAME already exists"
fi

if [ $(grep -c "^${USER_NAME}:" /etc/passwd) == 0 ]; then
  echo "Creating user $USER_NAME"
  adduser --system --no-create-home --shell /sbin/nologin --uid $LOCAL_USER_ID  --gid $LOCAL_GROUP_ID $USER_NAME
else
  echo "User $USER_NAME already exists"
fi

sed -i -e "s/user = .*$/user = $LOCAL_USER_ID/g" $PHP_CONF
sed -i -e "s/group = .*$/group = $LOCAL_GROUP_ID/g" $PHP_CONF

umask $UMASK

exec php-fpm
