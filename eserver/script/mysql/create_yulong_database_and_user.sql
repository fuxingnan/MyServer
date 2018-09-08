CREATE USER 'game'@'localhost' IDENTIFIED BY 'ghgame';

CREATE DATABASE yulong_game DEFAULT CHARACTER SET = utf8;
GRANT ALL PRIVILEGES ON yulong_game.* TO 'game'@'localhost';

CREATE DATABASE yulong_cent DEFAULT CHARACTER SET = utf8;
GRANT ALL PRIVILEGES ON yulong_cent.* TO 'game'@'localhost';

