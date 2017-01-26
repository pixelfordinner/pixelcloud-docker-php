#!/bin/sh

# This script will use LOCAL_USER_NAME and LOCAL_USER_ID
# as well as LOCAL_GROUP_NAME and LOCAL_GROUP_ID from env
# and create the user and group if they don't exist
# and then use them to start nginx with.
# If absent, will use nginx's alpine default config: nginx:nginx
# Not setting any env var will result in default image behaviour.

USER_NAME=${LOCAL_USER_NAME:-'www-data'}
GROUP_NAME=${LOCAL_GROUP_NAME:-'www-data'}
UMASK=${LOCAL_UMASK:-'002'}
PHP_CONF=/usr/local/etc/php-fpm.d/www.conf

echo "Starting php-fpm as ${USER_NAME}:${GROUP_NAME}"

if [ $(grep -c "^${GROUP_NAME}:" /etc/group) == 0 ]; then
  echo "Creating group $GROUP_NAME"
  addgroup -S -g $LOCAL_GROUP_ID $GROUP_NAME
else
  echo "Group $GROUP_NAME already exists"
fi

if [ $(grep -c "^${USER_NAME}:" /etc/passwd) == 0 ]; then
  echo "Creating user $USER_NAME"
  adduser -S -H -s /sbin/nologin -u $LOCAL_USER_ID $USER_NAME $GROUP_NAME
else
  echo "User $USER_NAME already exists"
fi

sed -i -e "s/user = .*$/user = $USER_NAME/g" $PHP_CONF
sed -i -e "s/group = .*$/group = $GROUP_NAME/g" $PHP_CONF

umask $UMASK

exec php-fpm
