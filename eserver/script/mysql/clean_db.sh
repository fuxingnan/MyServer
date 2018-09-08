#!/bin/bash

SCRIPT_PATH=~/Download/eserver
echo "clean game Database ..."
cd /opt/lampp/bin/
echo ${SCRIPT_PATH}
./mysql -u mygame -pfuxing220276  -e "source ~/Download/eserver/fx_db_clean.sql"

sudo rm -rf /tmp/screenlog_bash.log
#cat ${SCRIPT_PATH}//fx_db_clean.sql | mysql -u game --password=ghgame yulong_game