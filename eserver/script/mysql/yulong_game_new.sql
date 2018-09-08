-- SILP:db_schema:sql_create_table(guild)
CREATE TABLE IF NOT EXISTS `guild` (                                                  /*__SILP__*/
  `id` INT(11) NOT NULL COMMENT '编号',                                             /*__SILP__*/
  `name` VARCHAR(50) NOT NULL COMMENT '名称',                                       /*__SILP__*/
  `chief_id` INT(11) NOT NULL COMMENT '会长ID',                                     /*__SILP__*/
  `chief_name` VARCHAR(50) NOT NULL COMMENT '会长名称',                           /*__SILP__*/
  `level` INT(11) NOT NULL DEFAULT '0' COMMENT '等级',                              /*__SILP__*/
  `member_num` INT(11) NOT NULL DEFAULT '0' COMMENT '帮会人数',                   /*__SILP__*/
  `combat` INT(11) NOT NULL DEFAULT '0' COMMENT '战力',                             /*__SILP__*/
  `apply_num` INT(11) NOT NULL DEFAULT '0' COMMENT '申请人数',                    /*__SILP__*/
  `max_apply_num` INT(11) NOT NULL DEFAULT '0' COMMENT '最大申请人数',          /*__SILP__*/
  `notice` VARCHAR(250) NOT NULL COMMENT '公告'                                     /*__SILP__*/
) ENGINE=InnoDB DEFAULT CHARSET=utf8 CHECKSUM=1 DELAY_KEY_WRITE=1 ROW_FORMAT=DYNAMIC; /*__SILP__*/
                                                                                      /*__SILP__*/
ALTER TABLE `guild`                                                                   /*__SILP__*/
  ADD PRIMARY KEY (`id`);                                                             /*__SILP__*/
                                                                                      /*__SILP__*/
ALTER TABLE `guild`                                                                   /*__SILP__*/
  MODIFY `id` INT(11) NOT NULL AUTO_INCREMENT COMMENT '编号';                       /*__SILP__*/
                                                                                      /*__SILP__*/

-- SILP:db_schema:sql_create_table(guild_member)
CREATE TABLE IF NOT EXISTS `guild_member` (                                           /*__SILP__*/
  `guild_id` INT(11) NOT NULL COMMENT '公会ID',                                     /*__SILP__*/
  `player_id` INT(11) NOT NULL COMMENT '会员ID',                                    /*__SILP__*/
  `player_name` varchar(50) NOT NULL DEFAULT '' COMMENT '会员名称',               /*__SILP__*/
  `player_vip` tinyint(3) unsigned NOT NULL DEFAULT '0' COMMENT 'vip等级',          /*__SILP__*/
  `player_prof` tinyint(1) unsigned NOT NULL DEFAULT '0' COMMENT '职业',            /*__SILP__*/
  `player_level` smallint(6) NOT NULL DEFAULT '0' COMMENT '会员等级',             /*__SILP__*/
  `contribute` int(11) NOT NULL DEFAULT '0' ,                                         /*__SILP__*/
  `player_last_login` int(11) NOT NULL DEFAULT '0' ,                                  /*__SILP__*/
  `state` int(11) NOT NULL DEFAULT '0' ,                                              /*__SILP__*/
  `job` int(11) NOT NULL DEFAULT '0' ,                                                /*__SILP__*/
  `combat` int(11) NOT NULL DEFAULT '0'                                               /*__SILP__*/
) ENGINE=InnoDB DEFAULT CHARSET=utf8 CHECKSUM=1 DELAY_KEY_WRITE=1 ROW_FORMAT=DYNAMIC; /*__SILP__*/
                                                                                      /*__SILP__*/
ALTER TABLE `guild_member`                                                            /*__SILP__*/
  ADD PRIMARY KEY (`guild_id`,`player_id`);                                           /*__SILP__*/
                                                                                      /*__SILP__*/

-- SILP:db_schema:sql_create_table(fellow)
CREATE TABLE IF NOT EXISTS `fellow` (                                                                 /*__SILP__*/
  `id` INT(11) NOT NULL COMMENT '编号',                                                             /*__SILP__*/
  `player_id` INT(11) NOT NULL COMMENT '会员ID',                                                    /*__SILP__*/
  `data_id` smallint(6) NOT NULL COMMENT 'dataId',                                                    /*__SILP__*/
  `name` VARCHAR(50) NOT NULL COMMENT '昵称',                                                       /*__SILP__*/
  `quality` tinyint(3) unsigned NOT NULL DEFAULT '0' COMMENT '品质',                                /*__SILP__*/
  `zizhi_attack` INT(11) NOT NULL DEFAULT '0' COMMENT '攻击资质',                                 /*__SILP__*/
  `zizhi_hit` INT(11) NOT NULL DEFAULT '0' COMMENT '命中资质',                                    /*__SILP__*/
  `zizhi_critical` INT(11) NOT NULL DEFAULT '0' COMMENT '暴击资质',                               /*__SILP__*/
  `zizhi_guard` INT(11) NOT NULL DEFAULT '0' COMMENT '守护资质',                                  /*__SILP__*/
  `zizhi_bless` INT(11) NOT NULL DEFAULT '0' COMMENT '加持资质',                                  /*__SILP__*/
  `attr_attack` INT(11) NOT NULL DEFAULT '0' COMMENT '攻击',                                        /*__SILP__*/
  `attr_hit` INT(11) NOT NULL DEFAULT '0' COMMENT '命中',                                           /*__SILP__*/
  `attr_critical` INT(11) NOT NULL DEFAULT '0' COMMENT '暴击',                                      /*__SILP__*/
  `attr_guard` INT(11) NOT NULL DEFAULT '0' COMMENT '守护',                                         /*__SILP__*/
  `attr_bless` INT(11) NOT NULL DEFAULT '0' COMMENT '加持',                                         /*__SILP__*/
  `exp` INT(11) NOT NULL COMMENT '经验',                                                            /*__SILP__*/
  `level` smallint(6) NOT NULL DEFAULT '0' COMMENT '等级',                                          /*__SILP__*/
  `starlevel` tinyint(3) unsigned NOT NULL DEFAULT '0' COMMENT '星级',                              /*__SILP__*/
  `locked` tinyint(1) unsigned NOT NULL DEFAULT '0' COMMENT '锁定',                                 /*__SILP__*/
  `zzpoint` INT(11) NOT NULL COMMENT '资质点',                                                     /*__SILP__*/
  `fellow_skills_str` VARCHAR(100) NOT NULL COMMENT '伙伴技能（Erlang List Encoded as String）' /*__SILP__*/
) ENGINE=InnoDB DEFAULT CHARSET=utf8 CHECKSUM=1 DELAY_KEY_WRITE=1 ROW_FORMAT=DYNAMIC;                 /*__SILP__*/
                                                                                                      /*__SILP__*/
ALTER TABLE `fellow`                                                                                  /*__SILP__*/
  ADD PRIMARY KEY (`id`);                                                                             /*__SILP__*/
                                                                                                      /*__SILP__*/
ALTER TABLE `fellow`                                                                                  /*__SILP__*/
  MODIFY `id` INT(11) NOT NULL AUTO_INCREMENT COMMENT '编号';                                       /*__SILP__*/
                                                                                                      /*__SILP__*/

-- SILP:db_schema:sql_create_table(master)
CREATE TABLE IF NOT EXISTS `master` (                                                            /*__SILP__*/
  `id` INT(11) NOT NULL COMMENT '编号',                                                        /*__SILP__*/
  `name` VARCHAR(50) NOT NULL COMMENT '名称',                                                  /*__SILP__*/
  `chief_id` INT(11) NOT NULL COMMENT '师门师傅',                                            /*__SILP__*/
  `chief_name` VARCHAR(50) NOT NULL COMMENT '师傅名字',                                      /*__SILP__*/
  `member_num` TINYINT NOT NULL DEFAULT '0' COMMENT '师门人数',                              /*__SILP__*/
  `apply_num` TINYINT NOT NULL DEFAULT '0' COMMENT '申请人数',                               /*__SILP__*/
  `notice` VARCHAR(250) NOT NULL COMMENT '公告',                                               /*__SILP__*/
  `create_time` INT(11) NOT NULL COMMENT '公会创建时间',                                   /*__SILP__*/
  `torch` INT(11) NOT NULL DEFAULT '0' COMMENT '师门薪火值',                                /*__SILP__*/
  `skill_list` VARCHAR(50) NOT NULL COMMENT '师门技能标记',                                /*__SILP__*/
  `warn_liveness_time` INT(11) NOT NULL DEFAULT '0' COMMENT '活跃度警告时间',             /*__SILP__*/
  `warn_flag1` TINYINT NOT NULL DEFAULT '0' COMMENT '活跃度不够警告标识符',            /*__SILP__*/
  `warn_flag2` TINYINT NOT NULL DEFAULT '0' COMMENT '师傅不在线时间过长警告标识符' /*__SILP__*/
) ENGINE=InnoDB DEFAULT CHARSET=utf8 CHECKSUM=1 DELAY_KEY_WRITE=1 ROW_FORMAT=DYNAMIC;            /*__SILP__*/
                                                                                                 /*__SILP__*/
ALTER TABLE `master`                                                                             /*__SILP__*/
  ADD PRIMARY KEY (`id`);                                                                        /*__SILP__*/
                                                                                                 /*__SILP__*/
ALTER TABLE `master`                                                                             /*__SILP__*/
  MODIFY `id` INT(11) NOT NULL AUTO_INCREMENT COMMENT '编号';                                  /*__SILP__*/
                                                                                                 /*__SILP__*/

-- SILP:db_schema:sql_create_table(master_member)
CREATE TABLE IF NOT EXISTS `master_member` (                                          /*__SILP__*/
  `player_id` INT(11) NOT NULL COMMENT '弟子ID',                                    /*__SILP__*/
  `master_id` INT(11) NOT NULL COMMENT '师门ID',                                    /*__SILP__*/
  `player_name` VARCHAR(50) NOT NULL COMMENT '弟子名称',                          /*__SILP__*/
  `player_vip` INT(11) NOT NULL COMMENT 'vip等级',                                  /*__SILP__*/
  `guild_name` VARCHAR(50) NOT NULL COMMENT '所在帮会',                           /*__SILP__*/
  `player_prof` INT(11) NOT NULL COMMENT '职业',                                    /*__SILP__*/
  `player_level` INT(11) NOT NULL COMMENT '弟子等级',                             /*__SILP__*/
  `contribute` INT(11) NOT NULL COMMENT '战斗力',                                  /*__SILP__*/
  `torch` INT(11) NOT NULL COMMENT '薪火值',                                       /*__SILP__*/
  `player_last_logout` INT(11) NOT NULL COMMENT '离线时间',                       /*__SILP__*/
  `job` INT(11) NOT NULL COMMENT '职位'                                             /*__SILP__*/
) ENGINE=InnoDB DEFAULT CHARSET=utf8 CHECKSUM=1 DELAY_KEY_WRITE=1 ROW_FORMAT=DYNAMIC; /*__SILP__*/
                                                                                      /*__SILP__*/
ALTER TABLE `master_member`                                                           /*__SILP__*/
  ADD PRIMARY KEY (`player_id`,`master_id`);                                          /*__SILP__*/
                                                                                      /*__SILP__*/

-- SILP:db_schema:sql_create_table(master_apply)
CREATE TABLE IF NOT EXISTS `master_apply` (                                           /*__SILP__*/
  `player_id` INT(11) NOT NULL COMMENT '玩家id',                                    /*__SILP__*/
  `master_id` INT(11) NOT NULL COMMENT '师门id',                                    /*__SILP__*/
  `player_name` VARCHAR(50) NOT NULL COMMENT '玩家名字',                          /*__SILP__*/
  `guild_name` VARCHAR(50) NOT NULL COMMENT '帮会名字',                           /*__SILP__*/
  `player_lvl` INT(11) NOT NULL COMMENT '玩家等级',                               /*__SILP__*/
  `player_prof` INT(11) NOT NULL COMMENT '玩家职业',                              /*__SILP__*/
  `player_contribute` INT(11) NOT NULL COMMENT '战斗力',                           /*__SILP__*/
  `apply_time` INT(11) NOT NULL COMMENT '玩家申请时间'                          /*__SILP__*/
) ENGINE=InnoDB DEFAULT CHARSET=utf8 CHECKSUM=1 DELAY_KEY_WRITE=1 ROW_FORMAT=DYNAMIC; /*__SILP__*/
                                                                                      /*__SILP__*/
ALTER TABLE `master_apply`                                                            /*__SILP__*/
  ADD PRIMARY KEY (`player_id`,`master_id`);                                          /*__SILP__*/
                                                                                      /*__SILP__*/

-- SILP:db_schema:sql_create_table(player_attribs)
CREATE TABLE IF NOT EXISTS `player_attribs` (                                                         /*__SILP__*/
  `player_id` INT(11) NOT NULL COMMENT '会员ID',                                                    /*__SILP__*/
  `fellow_skills_str` VARCHAR(100) NOT NULL COMMENT '伙伴技能（Erlang List Encoded as String）' /*__SILP__*/
) ENGINE=InnoDB DEFAULT CHARSET=utf8 CHECKSUM=1 DELAY_KEY_WRITE=1 ROW_FORMAT=DYNAMIC;                 /*__SILP__*/
                                                                                                      /*__SILP__*/
ALTER TABLE `player_attribs`                                                                          /*__SILP__*/
  ADD PRIMARY KEY (`player_id`);                                                                      /*__SILP__*/
                                                                                                      /*__SILP__*/

