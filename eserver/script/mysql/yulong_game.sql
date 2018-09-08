-- phpMyAdmin SQL Dump
-- version 4.3.11
-- http://www.phpmyadmin.net
--
-- Host: 127.0.0.1
-- Generation Time: 2015-06-17 05:35:21
-- 服务器版本： 5.6.24
-- PHP Version: 5.6.8

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8 */;

--
-- Database: `yulong_game`
--

-- --------------------------------------------------------

--
-- 表的结构 `account`
--

CREATE TABLE IF NOT EXISTS `account` (
  `accname` varchar(50) NOT NULL DEFAULT '' COMMENT '平台账户',
  `sid` int(10) NOT NULL DEFAULT '0',
  `status` tinyint(1) NOT NULL DEFAULT '0' COMMENT '状态(0创建帐号,1加载创建角色,2创建角色,3进入游戏)',
  `time` int(11) unsigned DEFAULT '0' COMMENT '对应时间',
  `ip` varchar(15) DEFAULT '' COMMENT 'ip'
) ENGINE=InnoDB DEFAULT CHARSET=utf8 CHECKSUM=1 DELAY_KEY_WRITE=1 ROW_FORMAT=DYNAMIC;

-- --------------------------------------------------------

--
-- 表的结构 `card`
--

CREATE TABLE IF NOT EXISTS `card` (
  `id` varchar(36) NOT NULL COMMENT '卡号',
  `type` tinyint(4) unsigned NOT NULL COMMENT '卡类型',
  `state` tinyint(4) unsigned NOT NULL DEFAULT '0' COMMENT '状态(0未领取,1已领取)',
  `player_id` int(10) unsigned NOT NULL COMMENT '领取者id'
) ENGINE=MyISAM DEFAULT CHARSET=utf8 COMMENT='各种礼包卡';

-- --------------------------------------------------------

--
-- 表的结构 `counter`
--

CREATE TABLE IF NOT EXISTS `counter` (
  `player_id` int(11) NOT NULL COMMENT '玩家id',
  `data` text NOT NULL COMMENT '数据json'
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='玩家计数器';

-- --------------------------------------------------------

-- --------------------------------------------------------

--
-- 表的结构 `dungeon_exp`
--

CREATE TABLE IF NOT EXISTS `dungeon_exp` (
  `player_id` int(11) unsigned NOT NULL COMMENT '玩家ID',
  `phase` tinyint(3) unsigned NOT NULL COMMENT '时间段[1以前的记录,2当天]',
  `dungeon_type` tinyint(3) unsigned NOT NULL COMMENT '副本类型[1单人副本,2组队副本]',
  `count` int(5) unsigned DEFAULT NULL COMMENT '累计没有进入副本次数',
  `exp` int(11) unsigned DEFAULT NULL COMMENT '累计可获得的经验补偿',
  `last_login_time` int(11) unsigned DEFAULT NULL COMMENT '玩家最后登陆时间',
  `last_logout_lvl` smallint(5) unsigned DEFAULT NULL COMMENT '玩家最后退出时的等级'
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='副本经验补偿';

-- --------------------------------------------------------

--
-- 表的结构 `employee`
--

CREATE TABLE IF NOT EXISTS `employee` (
  `owner_id` int(10) NOT NULL DEFAULT '0' COMMENT '玩家id',
  `em_ids` varchar(50) NOT NULL DEFAULT '[]' COMMENT '雇佣的好友id列表'
) ENGINE=InnoDB DEFAULT CHARSET=utf8 CHECKSUM=1 DELAY_KEY_WRITE=1 ROW_FORMAT=DYNAMIC;

-- --------------------------------------------------------

--
-- 表的结构 `gm_ctrl`
--

CREATE TABLE IF NOT EXISTS `gm_ctrl` (
  `id` int(11) NOT NULL,
  `ctrl_type` tinyint(1) NOT NULL DEFAULT '0' COMMENT '控制类型:1.禁IP,2.禁登录,3.禁言',
  `begin_time` int(11) NOT NULL DEFAULT '0' COMMENT '开始时间',
  `end_time` int(11) NOT NULL DEFAULT '0' COMMENT '结束时间',
  `target` char(18) NOT NULL DEFAULT '' COMMENT '禁IP存IP,禁角色存ID'
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

-- --------------------------------------------------------

--
-- 表的结构 `goods`
--

CREATE TABLE IF NOT EXISTS `goods` (
  `id` int(11) NOT NULL COMMENT '唯一id',
  `player_id` int(11) unsigned NOT NULL COMMENT '玩家id',
  `goods_id` int(10) unsigned NOT NULL COMMENT '物品id(sys_goods)',
  `count` smallint(6) unsigned NOT NULL DEFAULT '1' COMMENT '物品数目',
  `repos` tinyint(4) unsigned NOT NULL DEFAULT '1' COMMENT '存储类型:1玩家背包，2玩家装备栏,3仓库',
  `pos` smallint(6) unsigned NOT NULL COMMENT '背包内物品位置,根据bagid不同而变化',
  `bind` tinyint(4) unsigned NOT NULL COMMENT '绑定类型，0为不可绑定，1为可绑定还未绑定，2为可绑定已绑定',
  `create_time` bigint(20) DEFAULT '0' COMMENT '物品超时，单位秒'
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='玩家物品表';
-- --------------------------------------------------------

--
-- 表的结构 `equip`
--
CREATE TABLE IF NOT EXISTS `equip` (
  `id` int(11) NOT NULL COMMENT '物品id（同goods)',
  `player_id` int(11) NOT NULL COMMENT '玩家id',
  `stren_level` tinyint(3) unsigned NOT NULL DEFAULT '0' COMMENT '当前强化等级',
  `stren_exp` int(10) unsigned NOT NULL DEFAULT '0' COMMENT '当前强化度',
  `stren_exp_total` int(10) unsigned NOT NULL DEFAULT '0' COMMENT '当前强化度',
  `star_count` tinyint(6) unsigned DEFAULT '0' COMMENT '打星数量',
  `star_times` smallint(6) unsigned DEFAULT '0' COMMENT '打星次数'
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='玩家装备表';

-- --------------------------------------------------------
--
-- 表的结构 `mail`
--

CREATE TABLE IF NOT EXISTS `mail` (
  `id` int(11) unsigned NOT NULL COMMENT '信件id',
  `recv_id` int(11) unsigned NOT NULL COMMENT '收件人id',
  `recv_name` varchar(28) NOT NULL COMMENT '收件人名字',
  `type` tinyint(1) unsigned NOT NULL COMMENT '类型（1系统/2私人）',
  `state_read` tinyint(1) unsigned NOT NULL COMMENT '读状态（1已读/2未读）',
  `state_lock` tinyint(11) unsigned NOT NULL DEFAULT '0' COMMENT '锁定状态:0未锁定，1锁定',
  `timestamp` int(11) NOT NULL COMMENT '发送时间',
  `send_id` int(11) unsigned NOT NULL COMMENT '发件人id',
  `send_name` varchar(28) NOT NULL COMMENT '发件人名字',
  `title` varchar(50) NOT NULL COMMENT '信件标题',
  `content` varchar(500) NOT NULL COMMENT '信件正文',
  `goods_uniq_id` int(10) unsigned NOT NULL COMMENT '物品唯一id',
  `goods_type_id` int(10) unsigned NOT NULL COMMENT '物品类型id',
  `goods_num` int(11) unsigned NOT NULL COMMENT '物品数量',
  `silver` int(11) unsigned NOT NULL COMMENT '银币数额',
  `gold` int(11) unsigned NOT NULL COMMENT '金币数额(只能系统邮件含有金币)',
  `money_bind` tinyint(4) unsigned NOT NULL DEFAULT '1' COMMENT '邮件中的钱是否绑定1非绑定 2绑定'
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='信件信息';

-- --------------------------------------------------------

--
-- 表的结构 `market`
--

CREATE TABLE IF NOT EXISTS `market` (
  `id` varchar(10) NOT NULL COMMENT '物品唯一id(同goods.id)',
  `player_id` int(11) unsigned NOT NULL COMMENT '挂售者id',
  `player_name` varchar(50) NOT NULL COMMENT '玩家名字',
  `goods_id` int(11) unsigned NOT NULL COMMENT '物品类型id(同表格goods)',
  `class` tinyint(4) unsigned NOT NULL COMMENT '商品类型,1普通物品，2装备，3钱币',
  `count` int(11) unsigned NOT NULL COMMENT '物品数量',
  `price_type` tinyint(4) unsigned NOT NULL COMMENT '价格类型(1银币，3为金币)',
  `price` int(11) unsigned NOT NULL COMMENT '价格',
  `color` tinyint(3) unsigned NOT NULL COMMENT '颜色，颜色值,绿蓝紫橙:2345',
  `career` tinyint(3) unsigned NOT NULL COMMENT '职业:职业限制:0无限制',
  `lvl` mediumint(8) unsigned NOT NULL COMMENT '等级',
  `expire_time` bigint(20) unsigned NOT NULL COMMENT '挂售截至时间(秒)',
  `expire_type` tinyint(4) unsigned NOT NULL COMMENT '挂售时间类型',
  `type` tinyint(4) unsigned NOT NULL COMMENT '物品类型',
  `subtype` tinyint(4) unsigned NOT NULL COMMENT '物品子类型',
  `sell_time` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '售卖时间'
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

-- --------------------------------------------------------

--
-- 表的结构 `mounts`
--

CREATE TABLE IF NOT EXISTS `mounts` (
  `id` int(11) unsigned NOT NULL,
  `player_id` int(10) NOT NULL COMMENT '玩家id',
  `type_id` int(10) unsigned NOT NULL COMMENT '坐骑类型id',
  `pos` tinyint(4) NOT NULL COMMENT '坐骑的位置',
  `name` varchar(50) NOT NULL COMMENT '坐骑的名字',
  `lvl` tinyint(4) NOT NULL COMMENT '等级',
  `stage` tinyint(1) NOT NULL COMMENT '坐骑的成长阶段',
  `exp` bigint(20) unsigned NOT NULL DEFAULT '0' COMMENT '坐骑的当前经验',
  `feed_exp` int(11) unsigned NOT NULL DEFAULT '0' COMMENT '当前喂养经验值',
  `state` tinyint(4) NOT NULL COMMENT '状态：1休息2骑乘',
  `state_fight` tinyint(4) unsigned NOT NULL DEFAULT '0' COMMENT '出战状态:0休息,1出战',
  `value` int(10) DEFAULT '0' COMMENT '身价(保留功能)',
  `str_prob` int(11) NOT NULL COMMENT '力量分配百分比',
  `agi_prob` int(11) NOT NULL COMMENT '敏捷分配百分比',
  `phys_prob` int(11) NOT NULL COMMENT '体质分配百分比',
  `wit_prob` int(11) NOT NULL COMMENT '智力分配百分比',
  `spirit_prob` int(11) NOT NULL COMMENT '精神分配百分比',
  `is_trans` tinyint(4) NOT NULL COMMENT '是否使用变身卡.0：不使用；1：使用 ',
  `transform_card` int(11) NOT NULL COMMENT '变身卡信息id',
  `active_mounts` text NOT NULL COMMENT '激活的幻化卡形象坐骑模型json列表[id1, id2, id3....]'
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

-- --------------------------------------------------------

--
-- 表的结构 `notice`
--

CREATE TABLE IF NOT EXISTS `notice` (
  `id` int(11) NOT NULL COMMENT 'id',
  `post_time` int(11) NOT NULL DEFAULT '0' COMMENT '发布时间',
  `plan_time` int(11) NOT NULL DEFAULT '0' COMMENT '开始时间',
  `end_time` int(11) NOT NULL DEFAULT '0' COMMENT '结束时间',
  `period` int(11) NOT NULL DEFAULT '0' COMMENT '间隔时间',
  `status` tinyint(4) NOT NULL DEFAULT '0' COMMENT '状态，是否可用，过期不可用，被禁公告不可用,1:可用，0:不可用',
  `content` varchar(500) NOT NULL COMMENT '内容'
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

-- --------------------------------------------------------

--
-- 表的结构 `player`
--

CREATE TABLE IF NOT EXISTS `player` (
  `id` int(11) unsigned NOT NULL COMMENT 'id',
  `accname` varchar(50) NOT NULL DEFAULT '' COMMENT '平台账户',
  `name` varchar(50) NOT NULL DEFAULT '' COMMENT '玩家名',
  `sex` tinyint(1) unsigned NOT NULL DEFAULT '1' COMMENT '性别',
  `career` tinyint(1) unsigned NOT NULL DEFAULT '0' COMMENT '职业',
  `mapid` int(11) unsigned NOT NULL DEFAULT '0' COMMENT '地图ID',
  `instance` int(10) unsigned NOT NULL DEFAULT '1' COMMENT '对应的地图实例id',
  `x` int(10) unsigned NOT NULL DEFAULT '0' COMMENT 'X坐标',
  `y` int(10) unsigned NOT NULL DEFAULT '0' COMMENT 'Y坐标',
  `lvl` smallint(6) unsigned NOT NULL DEFAULT '0' COMMENT '等级',
  `exp_cur` int(11) unsigned NOT NULL DEFAULT '0' COMMENT '当前经验',
  `exp` bigint(20) unsigned NOT NULL DEFAULT '0' COMMENT '总经验',
  `fury` int(10) unsigned NOT NULL DEFAULT '0' COMMENT '怒值',
  `hp` int(10) unsigned NOT NULL DEFAULT '0' COMMENT '血',
  `mp` int(10) unsigned NOT NULL DEFAULT '0' COMMENT '蓝',
  `silver` int(10) unsigned NOT NULL DEFAULT '0' COMMENT '银币',
  `silver_bind` int(11) unsigned NOT NULL DEFAULT '0' COMMENT '绑定银币',
  `gold` int(10) unsigned NOT NULL DEFAULT '0' COMMENT '金币',
  `gold_bind` int(10) unsigned NOT NULL COMMENT '绑定金币',
  `bag_count` tinyint(4) unsigned NOT NULL DEFAULT '0' COMMENT '背包中物品最大数目',
  `store_count` tinyint(3) unsigned NOT NULL DEFAULT '36' COMMENT '仓库格子数',
  `shortcut` text NOT NULL COMMENT '玩家的快捷栏,保存的内容为[{type, Id}]',
  `shortcut_cur` tinyint(3) unsigned NOT NULL DEFAULT '255' COMMENT '当前快捷栏',
  `buff` text NOT NULL COMMENT '玩家当前bufff',
  `cd_list` text NOT NULL COMMENT '玩家cd列表',
  `mounts_count` tinyint(4) NOT NULL DEFAULT '3' COMMENT '坐骑当前允许的最大数量',
  `pk_mode` tinyint(3) unsigned NOT NULL DEFAULT '1' COMMENT 'pk选项',
  `reg_time` int(10) unsigned NOT NULL COMMENT '注册时间',
  `last_login_time` int(11) NOT NULL DEFAULT '0' COMMENT '最后登录时间',
  `last_logout_time` int(10) unsigned NOT NULL DEFAULT '0' COMMENT '最后登出时间',
  `last_login_ip` varchar(15) NOT NULL COMMENT '最后登录ip',
  `total_played` int(10) unsigned NOT NULL DEFAULT '0' COMMENT '玩家总共游戏时间',
  `vip` tinyint(3) unsigned NOT NULL DEFAULT '0' COMMENT 'vip等级(1-10),0表示不是vip',
  `total_payment` int(11) unsigned NOT NULL COMMENT '累积充值金币',
  `title` text NOT NULL COMMENT '称号id',
  `glory` int(11) NOT NULL COMMENT '荣誉值',
  `success_point` int(10) unsigned NOT NULL DEFAULT '0' COMMENT '玩家的成就点数',
  `culture` int(10) unsigned NOT NULL DEFAULT '0' COMMENT '玩家的文采值',
  `kill_player` int(10) unsigned NOT NULL DEFAULT '0' COMMENT '玩家杀人数',
  `att_phy_max` int(10) unsigned NOT NULL DEFAULT '0' COMMENT '玩家攻击最大值',
  `hp_blood_pool` int(11) NOT NULL COMMENT '血池当前的血量',
  `mp_blood_pool` int(11) NOT NULL COMMENT '血池当前的魔法量',
  `pet_hp_blood_pool` int(11) NOT NULL COMMENT '血池当前的宠物血量'
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='用户信息';
--
-- Indexes for dumped tables
--

--
-- Indexes for table `player`
--
ALTER TABLE `player`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `name` (`name`),
  ADD KEY `accname` (`accname`);

-- --------------------------------------------------------

--
-- 表的结构 `rank`
--

CREATE TABLE IF NOT EXISTS `rank` (
  `type` tinyint(4) NOT NULL COMMENT '排行榜类型:1个人排行，2装备排行',
  `data` text NOT NULL COMMENT '数据(json or binary)'
) ENGINE=MyISAM DEFAULT CHARSET=utf8 COMMENT='排行表';

-- --------------------------------------------------------

--
-- 表的结构 `relation`
--

CREATE TABLE IF NOT EXISTS `relation` (
  `idA` int(11) unsigned NOT NULL DEFAULT '0' COMMENT '请求方id',
  `idB` int(11) unsigned NOT NULL DEFAULT '0' COMMENT '接受方id',
  `type` tinyint(1) unsigned NOT NULL DEFAULT '0' COMMENT '玩家间关系类型:1好友，2仇人，3黑名单',
  `intimate` int(11) unsigned DEFAULT '0' COMMENT '好友亲密度'
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='玩家关系';

-- --------------------------------------------------------

--
-- 表的结构 `setting`
--

CREATE TABLE IF NOT EXISTS `setting` (
  `id` int(10) NOT NULL DEFAULT '0' COMMENT '玩家id',
  `v0` text NOT NULL COMMENT '设置0（保存服务器也需要使用的设置)',
  `v1` text NOT NULL COMMENT '设置1（保存仅客户端使用的设置)',
  `v2` text NOT NULL COMMENT '设置2（保存仅客户端使用的设置)',
  `v3` text NOT NULL COMMENT '设置3（保存仅客户端使用的设置)',
  `v4` text NOT NULL COMMENT '设置4（保存仅客户端使用的设置)',
  `v5` text NOT NULL COMMENT '设置5（保存仅客户端使用的设置)'
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='玩家设置表';

-- --------------------------------------------------------


--
-- 表的结构 `skill`
--

CREATE TABLE IF NOT EXISTS `skill` (
  `player_id` int(10) unsigned NOT NULL DEFAULT '0' COMMENT '玩家id',
  `skill_id` int(11) unsigned NOT NULL DEFAULT '0' COMMENT '技能ID',
  `lvl` int(3) unsigned NOT NULL DEFAULT '0' COMMENT '等级'
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='玩家技能列表';

-- --------------------------------------------------------

--
-- 表的结构 `success`
--

CREATE TABLE IF NOT EXISTS `success` (
  `player_id` int(10) unsigned NOT NULL COMMENT '玩家id',
  `success_id` int(10) unsigned NOT NULL COMMENT '成就id',
  `state` tinyint(3) unsigned NOT NULL COMMENT '状态(1进行中,2完成)',
  `progress` int(10) unsigned NOT NULL COMMENT '进度值',
  `can_reward` tinyint(3) unsigned NOT NULL DEFAULT '1' COMMENT '是否可以领取奖励(0不可,1可以)'
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='玩家成就表';

-- --------------------------------------------------------
--
-- 表的结构 `task`
--

CREATE TABLE IF NOT EXISTS `task` (
  `player_id` int(10) unsigned NOT NULL,
  `task_id` int(10) unsigned NOT NULL,
  `task_type` tinyint(3) unsigned NOT NULL,
  `status` tinyint(3) unsigned NOT NULL,
  `track` text NOT NULL,
  `other` varchar(64) NOT NULL DEFAULT '[]' COMMENT 'task的其他数据'
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

-- --------------------------------------------------------

--
-- 表的结构 `vip`
--

CREATE TABLE IF NOT EXISTS `vip` (
  `id` int(11) NOT NULL DEFAULT '0' COMMENT '玩家id',
  `vip_lvl` int(10) NOT NULL DEFAULT '0' COMMENT 'vip类型',
  `vip_grow_lvl` int(11) NOT NULL DEFAULT '0' COMMENT 'vip成长等级',
  `vip_grow_exp` int(11) NOT NULL DEFAULT '0' COMMENT 'vip成长经验',
  `vip_endtime` int(11) NOT NULL DEFAULT '0' COMMENT 'vip结束时间'
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

-- --------------------------------------------------------

--
-- 表的结构 `world_data_disk`
--

CREATE TABLE IF NOT EXISTS `world_data_disk` (
  `wkey` varchar(50) NOT NULL DEFAULT '' COMMENT 'key',
  `val` text COMMENT 'val'
) ENGINE=InnoDB DEFAULT CHARSET=utf8 CHECKSUM=1 DELAY_KEY_WRITE=1 ROW_FORMAT=DYNAMIC;

--
-- Indexes for dumped tables
--

--
-- Indexes for table `account`
--
ALTER TABLE `account`
  ADD PRIMARY KEY (`accname`,`sid`), ADD KEY `ip` (`ip`);

--
-- Indexes for table `card`
--
ALTER TABLE `card`
  ADD PRIMARY KEY (`id`), ADD KEY `type` (`type`);

--
-- Indexes for table `counter`
--
ALTER TABLE `counter`
  ADD PRIMARY KEY (`player_id`);


--
-- Indexes for table `dungeon_exp`
--
ALTER TABLE `dungeon_exp`
  ADD PRIMARY KEY (`player_id`,`phase`,`dungeon_type`);

--
-- Indexes for table `employee`
--
ALTER TABLE `employee`
  ADD PRIMARY KEY (`owner_id`);

--
-- Indexes for table `equip`
--
ALTER TABLE `equip`
  ADD PRIMARY KEY (`id`), ADD KEY `player_id` (`player_id`);

--
-- Indexes for table `gm_ctrl`
--
ALTER TABLE `gm_ctrl`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `goods`
--
ALTER TABLE `goods`
  ADD PRIMARY KEY (`id`), ADD KEY `player_id` (`player_id`);


--
-- Indexes for table `mail`
--
ALTER TABLE `mail`
  ADD PRIMARY KEY (`id`), ADD KEY `send_id` (`send_id`), ADD KEY `recv_id` (`recv_id`);

--
-- Indexes for table `market`
--
ALTER TABLE `market`
  ADD PRIMARY KEY (`id`), ADD KEY `player_id` (`player_id`);

--
-- Indexes for table `mounts`
--
ALTER TABLE `mounts`
  ADD PRIMARY KEY (`id`), ADD KEY `player_id` (`player_id`);

--
-- Indexes for table `notice`
--
ALTER TABLE `notice`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `player`
--
ALTER TABLE `player`
  ADD PRIMARY KEY (`id`), ADD UNIQUE KEY `name` (`name`), ADD KEY `accname` (`accname`);


--
-- Indexes for table `rank`
--
ALTER TABLE `rank`
  ADD KEY `type` (`type`);

--
-- Indexes for table `relation`
--
ALTER TABLE `relation`
  ADD PRIMARY KEY (`idA`,`idB`,`type`), ADD KEY `idA` (`idA`);

--
-- Indexes for table `setting`
--
ALTER TABLE `setting`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `skill`
--
ALTER TABLE `skill`
  ADD UNIQUE KEY `id_sid` (`player_id`,`skill_id`), ADD KEY `id` (`player_id`);

--
-- Indexes for table `success`
--
ALTER TABLE `success`
  ADD PRIMARY KEY (`player_id`,`success_id`);

--
-- Indexes for table `task`
--
ALTER TABLE `task`
  ADD UNIQUE KEY `player_id` (`player_id`,`task_id`);

--
-- Indexes for table `world_data_disk`
--
ALTER TABLE `world_data_disk`
  ADD PRIMARY KEY (`wkey`);

--
-- AUTO_INCREMENT for dumped tables
--
-- AUTO_INCREMENT for table `gm_ctrl`
--
ALTER TABLE `gm_ctrl`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;
--
-- AUTO_INCREMENT for table `notice`
--
ALTER TABLE `notice`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT COMMENT 'id';
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
