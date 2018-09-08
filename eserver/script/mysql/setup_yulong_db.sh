#!/bin/bash

SCRIPT_PATH=`dirname $0`


echo "Drop User and Database ..."
if [ -z "$MYSQL_ROOT_PASSWD" ]; then
    cat ${SCRIPT_PATH}/drop_yulong_database_and_user.sql | mysql -u root
else
    cat ${SCRIPT_PATH}/drop_yulong_database_and_user.sql | mysql -u root -p${MYSQL_ROOT_PASSWD}
fi

echo "Create User and Database ..."
if [ -z "$MYSQL_ROOT_PASSWD" ]; then
    cat ${SCRIPT_PATH}/create_yulong_database_and_user.sql | mysql -u root
else
    cat ${SCRIPT_PATH}/create_yulong_database_and_user.sql | mysql -u root -p${MYSQL_ROOT_PASSWD}
fi

echo "Executing yulong_game.sql ..."
cat ${SCRIPT_PATH}/yulong_game.sql | mysql -u game --password=ghgame yulong_game

echo "Executing yulong_game_new.sql ..."
cat ${SCRIPT_PATH}/yulong_game_new.sql | mysql -u game --password=ghgame yulong_game

echo "Executing yulong_cent.sql ..."
cat ${SCRIPT_PATH}/yulong_cent.sql | mysql -u game --password=ghgame yulong_cent

echo "Executing yulong_cent_new.sql ..."
cat ${SCRIPT_PATH}/yulong_cent_new.sql | mysql -u game --password=ghgame yulong_cent

