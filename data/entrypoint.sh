#!/bin/sh

UMASK=${UMASK:-'002'}

umask $UMASK

exec php-fpm
