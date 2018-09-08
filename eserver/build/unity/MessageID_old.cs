//This code create by CodeEngine ,don't modify

using System;
 public enum MessageID :ushort
 {
 PACKET_NONE 					= 0 , //NONE
 PACKET_CG_LOGIN 				= 257, //client ask login 
 PACKET_GC_LOGIN_RET 			= 258, //client login result 

 PACKET_CG_CONNECTED_HEARTBEAT 	= 1,	//client connected heartbeat
PACKET_GC_CONNECTED_HEARTBEAT 	= 2,	//server connected heartbeat
PACKET_GC_NOTICE 				= 3,	//notice from server
PACKET_CG_SELECTROLE 			= 259,	//client send selectRole
PACKET_GC_SELECTROLE_RET 		= 260,	//server send select role result
PACKET_CG_CREATEROLE 			= 261,	//client send createRole
PACKET_GC_CREATEROLE_RET 		= 262,	//server send create role result
PACKET_CG_REQ_RANDOMNAME		= 263,	//Client Request Random Name
PACKET_GC_RET_RANDOMNAME		= 264,	//Server ret randomname

PACKET_GC_ENTER_SCENE 			= 513,	//Enter Scene
PACKET_CG_ENTER_SCENE_OK  		= 514,	//Client Enter Scene OK
PACKET_CG_REQ_CHANGE_SCENE 		= 515,	//Request Change Scene
PACKET_GC_CREATE_PLAYER 		= 516,	//Create Player
PACKET_GC_DELETE_OBJ			= 517,	//Delete Player
PACKET_CG_SYNC_POS 				= 518,	//Sync Position to Client
PACKET_GC_SYNC_POS 				= 519,	//Sync Position to Server
PACKET_CG_MOVE 					= 520,	//Player Move
PACKET_GC_MOVE 					= 521,	//Notify Character Move
PACKET_GC_STOP 					= 522,	//Notify Character Stop
PACKET_CG_REQ_NEAR_LIST 		= 523,	//client require nearby player list
PACKET_GC_NEAR_PLAYERLIST 		= 524,	//server send nearby player list to client
PACKET_GC_NEAR_TEAMLIST 		= 525,	//server send nearby team list to client
PACKET_GC_CREATE_NPC 			= 526,	//Create npc
PACKET_GC_PLAYSTORY 			= 527,	//send client playstory
PACKET_CG_PLAYSTORY_OVER 		= 528,	//send server playstory over
PACKET_CG_ASK_RELIVE 			= 529,	//send Ask Relive
PACKET_GC_RET_RELIVE 			= 530,	//send Ret Relive
PACKET_GC_DROPITEM_INFO 		= 531,	//send DropInfo
PACKET_CG_ASK_PICKUP_ITEM 		= 532,	//send Ask PickupItem
PACKET_GC_RET_PICKUP_ITEM 		= 533,	//send ret Pickup Item
PACKET_CG_ASK_SELOBJ_INFO	 	= 534,	//ask current select obj Info
PACKET_GC_RET_SELOBJ_INFO	 	= 535,	//send ret current select obj Info
PACKET_GC_DAMAGEBOARD_INFO = 536,	//Send DamageBoard Info to client
PACKET_CG_OPEN_COPYSCENE 		= 537,	//Send Open CopyScene Req to Server
PACKET_GC_COPYSCENE_INVITE 		= 538,	//Send CopyScene Invite Req to Client
PACKET_CG_COPYSCENE_INVITE_RET 	= 539,	//Send CopyScene Invite Ret to Server
PACKET_GC_COPYSCENE_RESULT		= 540,	//Send CopySceneResult to client
PACKET_CG_ASK_COPYSCENE_REWARD 	= 541,	//Send CopySceneReward to Server
PACKET_GC_RET_COPYSCENE_REWARD 	= 542,	//Send CopySceneReward to Client
PACKET_CG_ASK_COPYSCENE_SWEEP 	= 543,	//Send CopySceneSweep to Server
PACKET_GC_RET_COPYSCENE_SWEEP 	= 544,	//Send CopySceneSweep to Client
PACKET_GC_PLAY_EFFECT 			= 545,	//Server Send Player Use Tool
PACKET_GC_OP_TELEPORT 			= 546,	//Server Op CopyScene Teleport
PACKET_GC_OP_QINGGONGPOINT 		= 547,	//Server Op CopyScene QingGongPoint
PACKET_GC_SCENE_TIMESCALE 		= 548,	// Server Change Scene Time Scale
PACKET_CG_LEAVE_COPYSCENE 		= 549,	// Client Leave Copyscene
PACKET_GC_UPDATE_ANIMATION_STATE = 550,	//Update Animation state
PACKET_CG_CHANGE_MAJORCITY 		= 551,	//Request Change Major City
PACKET_CG_ASK_QUIT_GAME 		= 552,	//Ask Change Game Selece Scene
PACKET_GC_RET_QUIT_GAME 		= 553, 	//Ret Change Game Selece
PACKET_GC_SYNC_REACHEDSCENE 	= 554,	//Send Reached Scene
PACKET_GC_FORCE_SETPOS 			= 555,	//Server Force Set Player Pos
PACKET_GC_DEBUG_MY_POS 			= 556,	//Server Debug Player Pos


//————————————————玩家信息——————————————————
PACKET_CG_COMBATVALUE_ASK 		= 769,	//Client Ask Player CombatValue From Server
PACKET_GC_COMBATVALUE_RET 		= 770,	//Server Send Player CombatValue To Client
PACKET_CG_ASK_PKINFO 			= 771,	//Ask PK Info
PACKET_GC_RET_PKINFO 			= 772,	//Ret PK Info
PACKET_CG_CHANGE_PKMODLE 		= 773,	//ask change PK Modle
PACKET_GC_RET_CHANGE_PKMODLE 	= 774,	//Ret change PK Modle
PACKET_GC_CHANGE_PKLIST 		= 775,	// change PKList
PACKET_CG_REQ_CHALLENGE 		= 776,	//request PK somebody
PACKET_GC_BROADCAST_ATTR 		= 777,	//Server Broadcast Attr
PACKET_GC_SYN_ATTR 				= 778,	//Server Syn Attr
PACKET_CG_USER_BEHAVIOR 		= 779,	//client send behavior
PACKET_CG_ASK_ROLE_DATA			= 780,	//ask role data
PACKET_GC_RET_ROLE_DATA			= 781,	//ret role data


//————————————————任务信息——————————————————

PACKET_GC_MISSION_SYNC_MISSIONLIST = 1025,	//server send mission list to client
PACKET_CG_ACCEPTMISSION 		= 1026,	//ask to accept mission
PACKET_GC_ACCEPTMISSION_RET 	= 1027,	//result of accept mission
PACKET_CG_COMPLETEMISSION 		= 1028,	//ask to complete mission
PACKET_GC_COMPLETEMISSION_RET 	= 1029,	//result of complete mission
PACKET_CG_ABANDONMISSION 		= 1030,	//ask to abandon mission
PACKET_GC_ABANDONMISSION_RET 	= 1031,	//result of abandon mission
PACKET_GC_MISSION_STATE 		= 1032,	//update mission state
PACKET_GC_MISSION_PARAM 		= 1033,	//upstate mission param
PACKET_GC_MISSION_IGNOREMISSIONPREFLAG = 1034,	//Send ignoremissionpreflag to client
PACKET_CG_DAILYMISSION_UPDATE 	= 1035,	//Ask to update DailyMission
PACKET_GC_DAILYMISSION_UPDATE_RET = 1036,	//Send DailyMission UpdateData


//————————————————技能相关——————————————————
PACKET_CG_SKILL_USE 			= 1281,	//client send use skill
PACKET_GC_RET_USE_SKILL			= 1282,	//Use Skill ret
PACKET_GC_CDTIME_UPDATE			= 1283,	//Server Update CDTime
PACKET_GC_SKILL_FINISH			= 1284,	// Server Skill Finish
PACKET_GC_SKILL_STUDY			= 1285,	// Server Send StudyInfo
PACKET_GC_SYN_SKILLINFO			= 1286,	//Server Syn Skill Info
PACKET_GC_UPDATE_SCENE_INSTACTIVATION = 1287,	//Update Scene InstActivation
PACKET_GC_UPDATE_HITPONIT		= 1288,	//Update HitPoint
PACKET_CG_ASK_LEVELUPSKILL		= 1289,	//Ask LevelUpSkill
PACKET_GC_ATTACKFLY				= 1290,	//Attak fly
PACKET_GC_UPDATE_ACTIVE_FELLOWSKILL = 1291,	//Update Fellow Active Skill
PACKET_CG_EQUIP_FELLOW_SKILL 	= 1292,	//Equip Fellow Skill
PACKET_GC_EQUIP_FELLOW_SKILL_RET = 1293,	//Equip Fellow Skill Ret
PACKET_CG_UNEQUIP_FELLOW_SKILL 	= 1294,	//UnEquip Fellow Skill
PACKET_GC_UNEQUIP_FELLOW_SKILL_RET = 1295,	//UnEquip Fellow Skill Ret
PACKET_CG_LEVELUP_FELLOW_SKILL 	= 1296,	//LevelUp Fellow Skill
PACKET_GC_LEVELUP_FELLOW_SKILL_RET = 1297,	//LevelUp Fellow Skill Ret



//—————————————————聊天——————————————————————
PACKET_CG_CHAT 					= 1537,	//Client send chat info
PACKET_GC_CHAT 					= 1538,	//Server send chat info
PACKET_CG_GMCOMMAND  			= 1539,	//send gm command
PACKET_CG_ASK_LOUDSPEAKER_POOL 	= 1540,	//Client Ask LoudSpeaker Pool
PACKET_GC_ASK_LOUDSPEAKER_CONTENT = 1541, 	//Server Ask Client LoudSpeaker Content



//—————————————————活动——————————————————————
PACKET_CG_ASK_NEWSERVERAWARD 	= 1793,	//client ask to get NewServerAward
PACKET_GC_NEWSERVERAWARD_DATA 	= 1794,	//Send NewServerAward Data to client
PACKET_CG_ASK_DAYAWARD 			= 1795,	//client ask to get DayAward
PACKET_GC_DAYAWARD_DATA 		= 1796,	//Send DayAward Data to client
PACKET_CG_ASK_ONLINEAWARD 		= 1797,	//client ask to get OnlineAward
PACKET_GC_ONLINEAWARD_DATA 		= 1798,	//Send OnlineAward Data to client
PACKET_CG_ASK_ACTIVENESSAWARD 	= 1799,	//client ask to get ACTIVENESSAWARD
PACKET_GC_ASK_ACTIVENESSAWARD_RET = 1800,	//Send ACTIVENESSAWARD ret to client
PACKET_GC_SYNC_ACTIVENESSAWARD 	= 1801,	//Sync ACTIVENESSAWARD Data to client
PACKET_CG_MONEYTREE_ASKAWARD 	= 1802,	//MoneyTree client ask server award
PACKET_GC_MONEYTREE_DATA 		= 1803,	//Server sync moneytree data to client


//————————————————美人————————————————————————
PACKET_GC_BELLE_DATA 			= 2049,	//server send bell data
PACKET_CG_BELLE_CLOSE 			= 2050,	//client send belle close
PACKET_GC_BELLE_CLOSE_RET 		= 2051,	//server ret belle close
PACKET_CG_BELLE_EVOLUTION 		= 2052,	//client send belle evolution
PACKET_GC_BELLE_EVOLUTION_RET 	= 2053,	//server send belle evolution ret
PACKET_CG_BELLE_EVOLUTIONRAPID 	= 2054,	//client send belle evolution rapid
PACKET_GC_BELLE_EVOLUTIONRAPID_RET = 2055,	//server send belle evolution rapid ret
PACKET_CG_BELLE_BATTLE 			= 2056,	//client send belle battle
PACKET_GC_BELLE_BATTLE_RET		= 2057,	//server send belle battle ret
PACKET_CG_BELLE_REST 			= 2058,	//client send belle rest
PACKET_GC_BELLE_REST_RET		= 2059,	//server send belle rest ret
PACKET_CG_BELLE_ACTIVEMATRIX 	= 2060,	//client send belle Matrix active
PACKET_GC_BELLE_ACTIVEMATRIX_RET = 2061,	//server send belle Matrix Active ret
PACKET_GC_BELLE_ACTIVE 			= 2062,	//server send belle Active

//——————————————————黑市商人——————————————————
PACKET_CG_ASK_BLACKMARKETITEMINFO = 2305,	//Ask BlackMarket Item info
PACKET_GC_RET_BLACKMARKETITEMINFO = 2306,	//Ret BlackMarket Item info
PACKET_CG_BUY_BLACKMARKETITEM 	= 2307,	//Buy BlackMarket Item
PACKET_GC_CLOSE_BLACKMARKET 	= 2308,	//Close BlackMarket Item
PACKET_GC_SHOW_BLACKMARKET		= 2309,	//Server Show YuanBaoShop BlackMarket



PACKET_CG_ASK_YUANBAOSHOP_OPEN 	= 2561,	//Client Ask YuanBaoShop Open
PACKET_CG_BUY_YUANBAOGOODS 		= 2562,	//Client Buy YuanBaoShop Goods
PACKET_GC_RET_YUANBAOSHOP_OPEN 	= 2563,	//Server Ret YuanBaoShop Open
PACKET_GC_SERVER_CONFIG 		= 2564, 	//server Config
PACKET_CG_BUY_FASHION			= 2565,	//Client Buy Fashion
PACKET_CG_BUY_STAMINA			= 2566,	//Client Buy Stamina
PACKET_CG_SYSTEMSHOP_BUY 		= 2567,	//client buy from systemshop
PACKET_CG_SYSTEMSHOP_BUYBACK 	= 2568,	//client buy back from systemshop
PACKET_CG_SYSTEMSHOP_VIEW		= 2570,	//client ask view systemshop
PACKET_CG_WEAR_FASHION 			= 2571,	//Client Wear Fashion
PACKET_GC_SYSTEMSHOP_MERCHANDISELIST = 2572,	//Server send MerchandiseList to client





PACKET_CG_GUILD_REQ_LIST 		= 2817,	//Guild Client Req All Server Guild Info
PACKET_GC_GUILD_RET_LIST 		= 2818,	//Guild Server Ret All Server Guild Info
PACKET_CG_GUILD_REQ_INFO 		= 2819,	//Guild Client Req Self Guild Info
PACKET_GC_GUILD_RET_INFO 		= 2820,	//Guild Server Ret Self Guild Info
PACKET_CG_GUILD_REQ_CHANGE_NOTICE = 2821,	//Guild Client Req Change Guild Notice
PACKET_CG_GUILD_CREATE 			= 2822,	//Guild Client Req Create Guild
PACKET_GC_GUILD_CREATE 			= 2823,	//Guild Server Ret Create Guild
PACKET_CG_GUILD_JOIN 			= 2824,	//Guild Client Req Join Guild
PACKET_GC_GUILD_JOIN 			= 2825,	//Guild Server Ret Join Guild
PACKET_CG_GUILD_LEAVE 			= 2826,	//Guild Client Req Leave Guild
PACKET_GC_GUILD_LEAVE 			= 2827,	//Guild Server Ret Leave Guild
PACKET_CG_GUILD_KICK 			= 2828,	//Guild Client Req Kick Guild
PACKET_CG_GUILD_JOB_CHANGE 		= 2829,	//Guild Client Req Change Member Job
PACKET_CG_GUILD_APPROVE_RESERVE = 2830,	//Guild Client Req Approve Reserve Member
PACKET_CG_GUILD_REQ_LEVELUP 	= 2831,	//Guild Client Req Guild Level Up
PACKET_GC_GUILD_RET_LEVELUP 	= 2832,	//Guild Server Ret Guild Level Up

PACKET_GC_UPDATEITEM =3073,
PACKET_CG_USE_ITEM =3074,
PACKET_GC_USE_ITEM_RET =3075,
PACKET_CG_EQUIP_ITEM =3076,
PACKET_CG_UNEQUIP_ITEM =3077,
PACKET_CG_THROW_ITEM =3078,
PACKET_CG_PUT_ITEM_STORAGEPACK =3079,
PACKET_GC_PUT_ITEM_STORAGEPACK_RET =3080,
PACKET_CG_TAKE_ITEM_STORAGEPACK =3081,
PACKET_GC_TAKE_ITEM_STORAGEPACK_RET =3082,
PACKET_CG_STORAGEPACK_UNLOCK =3083,
PACKET_CG_BACKPACK_UNLOCK =3084,
PACKET_GC_BACKPACK_RESIZE =3085,
PACKET_CG_EQUIP_ENCHANCE =3086,
PACKET_GC_EQUIP_ENCHANCE_RET =3087,
PACKET_CG_EQUIP_STAR =3088,
PACKET_GC_EQUIP_STAR_RET =3089,
PACKET_CG_PUT_GEM =3090,
    
PACKET_GC_PUT_GEM_RET =3091, 
PACKET_CG_TAKE_GEM =3092,
PACKET_GC_TAKE_GEM_RET =3093,
PACKET_GC_UPDATE_GEM_INFO =3094,
PACKET_GC_SHOW_USEITEMREMIND =3095,
PACKET_GC_SHOW_ITEMREMIND =3096,
PACKET_GC_SHOW_EQUIPREMIND =3097,
PACKET_CG_ASK_UPDATE_STORAGEPACK =3098,
PACKET_GC_UPDATE_STORAGEPACK =3099,
PACKET_GC_ASK_UPDATE_STORAGEPACK_RET =3100,
PACKET_GC_RET_PUT_GEM = 3101,
PACKET_CG_SYSTEMSHOP_SELL = 3102,	//client sell to systemshop


PACKET_GC_MAIL_UPDATE 			= 3329,	//server update mail
PACKET_GC_MAIL_DELETE 			= 3330,	//server del mail
PACKET_CG_MAIL_SEND 			= 3331,	//client send mail
PACKET_CG_MAIL_OPERATION 		= 3332,	//client op mail



PACKET_GC_MOUNTCOLLECTED_FLAG 	= 3585,	//Sync MountCollected flag
PACKET_GC_MOUNT_DATA 			= 3586,	//Sync Mount Status
PACKET_CG_MOUNT_MARK 			= 3587,	//client send Mount MarkAutoMoutID
PACKET_GC_MOUNT_MARK_RET 		= 3588,	//server send Mount MarkAutoMoutID ret
PACKET_CG_MOUNT_MOUNT 			= 3589,	//client send Mount ride mount
PACKET_CG_MOUNT_UNMOUNT 		= 3590,	//client send Mount unmount



//——————————————玩家关系——————————————
PACKET_CG_ADDFRIEND 			= 3841,	//Client Req Add Friend
PACKET_GC_ADDFRIEND 			= 3842,	//Server Ret Add Friend
PACKET_CG_DELFRIEND 			= 3843,	//Client Req Del Friend
PACKET_CG_REQ_FRIEND_USERINFO 	= 3844,	//Client Req Update Friend UserInfo
PACKET_GC_RET_FRIEND_USERINFO 	= 3845,	//Server Ret Update Friend UserInfo
PACKET_GC_DELFRIEND 			= 3846,	//Server Ret Del Friend
PACKET_GC_NOTICE_ADDED_FRIEND 	= 3847,	//Server Notice Client be added by Other Player
PACKET_GC_SYC_FRIEND_STATE 		= 3848,	//Server Syc One Friend State
PACKET_GC_SYC_FRIEND_INFO 		= 3849,	//Server Syc One Friend Info
PACKET_GC_SYC_FULL_FRIEND_LIST 	= 3850,	//Server Syc Full Friends List
PACKET_CG_ADDBLACKLIST 			= 3852,	//Client Req Add BlackList
PACKET_GC_ADDBLACKLIST 			= 3853,	//Server Ret Add BlackList
PACKET_GC_SYC_FULL_BLACK_LIST 	= 3854,	//Server Syc Full Black List
PACKET_CG_DELBLACKLIST 			= 3855,	//Client Req Del BlackList
PACKET_GC_DELBLACKLIST 			= 3856,	//Server Ret Del BlackList
PACKET_CG_FINDPLAYER 			= 3857,	//Client Req Find Player
PACKET_GC_FINDPLAYER 			= 3858,	//Server Ret Find Player Result
PACKET_GC_SYNSELTRAGET_ATTR     = 3859,	//Server Syn SelectObj Attr
PACKET_GC_SYC_FULL_HATE_LIST    = 5750,	//Server Syc Full Hate List
PACKET_CG_DELHATELIST           = 5751,	//Client Req Del HateList
PACKET_GC_DELHATELIST           = 5752,	//Server Ret Del HateList
PACKET_GC_ADDHATELIST           = 5755,	//Server Add Hate List




PACKET_CG_REQ_TEAM_INVITE 		= 4097,	//client request invite other player join team
PACKET_CG_REQ_TEAM_JOIN 		= 4098,	//client request join other player team
PACKET_CG_REQ_TEAM_LEAVE 		= 4099,	//client request leave team
PACKET_CG_REQ_TEAM_KICK_MEMBER 	= 4100,	//client req kick team member
PACKET_CG_REQ_TEAM_CHANGE_LEADER = 4101,	//client req change leader
PACKET_GC_TEAM_LEAVE 			= 4102,	//client leave team
PACKET_GC_TEAM_SYNC_TEAMINFO 	= 4103,	//server send full team info to client
PACKET_GC_TEAM_SYNC_MEMBERINFO 	= 4104,	//server send member info to client
PACKET_GC_JOIN_TEAM_INVITE 		= 4105,	//server send join team invite to client
PACKET_CG_JOIN_TEAM_INVITE_RESULT = 4106,	//client send join team invite result to server
PACKET_GC_JOIN_TEAM_REQUEST 	= 4107,	//server send join team request to client
PACKET_CG_JOIN_TEAM_REQUEST_RESULT = 4108,	//client send join team request result to server




PACKET_GC_UPDATE_ALL_TITLEINVESTITIVE = 4353,	//Server Update All TitleInvestitive
PACKET_CG_ACTIVE_TITLE 			= 4354,	//Client Active Title
PACKET_CG_DELETE_TITLE 			= 4355,	//Client Delete Title
PACKET_GC_GAIN_TITLE 			= 4356,	//Server Gain Title
PACKET_GC_DELETE_TITLE 			= 4357,	//Server Delete Title
PACKET_GC_ACTIVE_TITLE 			= 4358,	//Server Active Title
PACKET_GC_SYNC_ACTIVETITLE 		= 4359,	//Server Active Title




PACKET_GC_WORLDBOSS_DEAD 		= 4609,	//notify world boss is dead
PACKET_CG_WORLDBOSS_TEAMLIST_REQ = 4610,	//request world boss team list
PACKET_GC_WORLDBOSS_TEAMLIST 	= 4611,	//world boss team rank list
PACKET_GC_WORLDBOSS_OPEN 	 	= 4612,	//world boss is ready
PACKET_CG_WORLDBOSS_CHALLENGE 	= 4613,	//request challenge boss team
PACKET_CG_WORLDBOSS_JOIN  		= 4614,	//request kill world boss



PACKET_GC_UPDATE_FELLOW 		= 4865,	//send update fellow
PACKET_GC_CREATE_FELLOW 		= 4866,	//Create fellow
PACKET_CG_CALL_FELLOW 			= 4867,	//Call Fellow
PACKET_GC_CALL_FELLOW_RET 		= 4868,	//Call Fellow Ret
PACKET_CG_UNCALL_FELLOW 		= 4869,	//
PACKET_GC_UNCALL_FELLOW_RET 	= 4870,	//UnCall Fellow Ret
PACKET_CG_LOCK_FELLOW 			= 4871,	//Lock Fellow
PACKET_CG_UNLOCK_FELLOW 		= 4872,	//UnLock Fellow
PACKET_CG_RESOLVE_FELLOW 		= 4873, 	//Resolve Fellow
PACKET_GC_RESOLVE_FELLOW_RET 	= 4874,	//Resolve Fellow Ret
PACKET_CG_ASK_GAIN_FELLOW 		= 4875,	//Client Ask Gain Fellow
PACKET_GC_ASK_GAIN_FELLOW_RET 	= 4876,	//Ask Gain Fellow Ret
PACKET_GC_UPDATE_GAIN_FELLOW_COUNT = 4877,	//Update Gain Fellow Count
PACKET_CG_FELLOW_STAR 			= 4878,	//Fellow Star
PACKET_GC_FELLOW_STAR_RET		= 4879,	//Fellow Star Ret
PACKET_CG_FELLOW_ENCHANCE 		= 4880,	//Fellow Enchance
PACKET_GC_FELLOW_ENCHANCE_RET 	= 4881,	//Fellow Enchance Ret
PACKET_CG_FELLOW_APPLY_POINT 	= 4882,	//Fellow Apply Point
PACKET_GC_FELLOW_APPLY_POINT_RET = 4883,	//Fellow Apply Point Ret
PACKET_CG_ASK_GAIN_10_FELLOW 	= 4884,	//Client Ask Gain 10 Fellow
PACKET_GC_ASK_GAIN_10_FELLOW_RET = 4885,	//Ask Gain 10 Fellow Ret
PACKET_CG_FELLOW_CHANGE_NAME    = 4886,	//client send change fellow name
PACKET_GC_FELLOW_CHANGE_NAME_RET = 4887,	//client send change fellow name ret





PACKET_GC_CHALLENGE_MYDATA 		= 5121,	//challenge rank's data
PACKET_CG_CHALLENGERANKLIST_REQ = 5122,	//request challenge rank list
PACKET_GC_CHALLENGERANKLIST 	= 5123,	// challenge rank list
PACKET_GC_CHALLENGE_REWARD 		= 5124,	//Challenge rank reward
PACKET_GC_CHALLENGE_HISTORY 	= 5125,	//Challenge history
PACKET_CG_ASK_RANK 				= 5126,	// Ask Rank To Server
PACKET_GC_RET_RANK 				= 5127,	// Ret Rank to Client





PACKET_GC_UI_NEWPLAYERGUIDE 	= 5377,	// Server Send Client NewPlayerGuide
PACKET_GC_PLAY_MODELSOTRY 		= 5378,	//Server Send Client 3D Story
PACKET_GC_PLAYSHANDIANLIANEFFECT = 5379,	//shandianlian Effect
PACKET_GC_UI_OPERATION 			= 5380,	// ui operation



PACKET_GC_COUNTDOWN 			= 5633,	//show countdown
PACKET_GC_USERTIP 				= 5634,	//Server Send Client Tip
PACKET_GC_PLAY_SOUNDS 			= 5635,	//Server PlaySounds
PACKET_CG_SCENE_CHANGEINST 		= 5636,	//client send change channle request
PACKET_GC_SYNC_COPYSCENENUMBER 	= 5637,	//Sync CopySceneNumber to Client
PACKET_CG_COPYSCENERESET 		= 5638,	//Sync CopySceneReset to Client
PACKET_CG_CHANGE_SHOWFASHION 	= 5639,	//Client Change ShowFashion
PACKET_GC_CHANGE_SHOWFASHION 	= 5640,	//Server Change ShowFashion
PACKET_CG_USE_LIVINGSKILL 		= 5641,  	//Client Use LivingSkill Formula
PACKET_GC_CREATE_SNARE 			= 5642,	//Create SnareObj
PACKET_CG_PRELIMINARY_APPLYGUILDWAR = 5643,	//Apply preliminary GuildWar
PACKET_CG_ASK_PRELIMINARY_WARINFO = 5644,	//Ask  preliminary war info
PACKET_GC_RET_PRELIMINARY_WARINFO = 5645,	//Ret preliminary war info
PACKET_GC_SYN_TORCH_VALUE 		= 5646,	//Syn Torch Value
PACKET_CG_ASK_TORCH_VALUE 		= 5647,	//Ask Torch Value
PACKET_GC_ASK_STARTGUILDWAR 	= 5648,	//Ask  Star war
PACKET_CG_RET_STARTWAR 			= 5649,	//Ret Star war
PACKET_GC_SHOW_PRELIMINARY_WARRET = 5650,	//Show preliminary war Ret info
PACKET_CG_QIANKUNDAI_COMBINE 	= 5651,	//Client Combine QianKunDai Formula
PACKET_GC_QIANKUNDAI_PRODUCT 	= 5652,	//Server Send Combine Product
PACKET_CG_ACTIVE_FELLOW_SKILL 	= 5653,	//Client Ask Active Fellow Skill

PACKET_CG_FIGHTGUILDWARPOINT 	= 5655,	//Client Fight GuildWar Point
PACKET_CG_ASK_FINALGUILDWARGROUPINFO = 5656,	//Client Ask FinalGuildWar GroupInfo
PACKET_CG_ASK_FINALGUILDWARPOINTINFO = 5657,	//Client Ask FinalGuildWar PointInfo
PACKET_GC_RET_FINALGUILDWARGROUPINFO = 5658,	//Ret  FinalGuildWar Group Info
PACKET_GC_RET_FINALGUILDWARPOINTINFO = 5659,	//Ret FinalGuildWar Point Info
PACKET_GC_UPDATE_STAMINA_TIME 	= 5660,	//Server Sync Stamina Remain Time
PACKET_GC_LOGIN_QUEUE_STATUS 	= 5661,	//login queue status
PACKET_GC_OPENFUNCTION 			= 5665,	//Server Open function
PACKET_CG_ASK_OTHERROLE_DATA 	= 5666,	//client ask other player data
PACKET_GC_RET_OTHERROLE_DATA 	= 5667,	//server send other plater data to client
PACKET_CG_ASK_HIDE_FELLOW 		= 5668,	//Client Ask Hide Fellow
PACKET_CG_ASK_SHOW_FELLOW 		= 5669,	//Client Ask Show Fellow
PACKET_CG_CYPAY_SUCCESS 		= 5672,	//Client Send pay success
PACKET_CG_VISIT_SWORDSMAN 		= 5673,	//Client Send  SwordsMan
PACKET_CG_SWORDSMAN_LEVELUP  	= 5674,	//Client Send  SwordsMan levelup
PACKET_CG_BUY_SWORDSMAN 		= 5675,	//Client Send  buy SwordsMan
PACKET_CG_EQUIP_SWORDSMAN 		= 5676,	//Client Send EquipSwordsMan
PACKET_CG_UNEQUIP_SWORDSMAN		= 5677,	//Client Send UnEquipSwordsMan
PACKET_GC_UPDATE_SWORDSMAN 		= 5678,	//Server update SwordsMan
PACKET_GC_UPDATE_SWORDSMAN_VISITSTATE = 5679,	//Server update SwordsManstate
PACKET_GC_ACTIVITYNOTICE 		= 5680,	//Server send ActivityNotice
PACKET_CG_FELLOW_RESET_POINT 	= 5681,	//Client Ask Reset Fellow Point
PACKET_GC_RET_FELLOW_RESET_POINT = 5682,	//Server Ret Reset Fellow Point
PACKET_CG_REQ_POWERUP 			= 5683,	//Client power up
PACKET_GC_RES_POWERUP 			= 5684,	//Server send power up
PACKET_GC_POWERUP_LIST 			= 5685,	//Server send power up list
PACKET_GC_BUY_GUILDGOODS 		= 5686,	//Server Send Buy GuildShop Goods Result
PACKET_GC_SYNC_AWARDTABLE 		= 5687,	//Server send OnlineAwardTable to Client
PACKET_GC_GUILD_NEWRESERVE 		= 5690,	//Server send Guild Chief And Vice-Chief that their guild have new reserver member
PACKET_GC_SHOW_SKILLNAME 		= 5691,	//Server Show Skill Name
PACKET_CG_ASK_CURGUILDWARTYPE 	= 5692,	//Ask current guidwarType
PACKET_GC_RET_CURGUILDWARTYPE 	= 5693,	//Ret current guidwarType
PACKET_CG_SET_DEATH_PUSH 		= 5694,	//set death push flag
PACKET_GC_SWORDSMANPACK_RESIZE 	= 5695,	//Update SwordsManPack Size,ÉÏÒ»´ÎÏûÏ¢°üÃû×Ö´íÁË
PACKET_GC_RET_VISIT_SWORDSMAN 	= 5696,	//RET_VISITSWORDSMAN
PACKET_GC_RET_LEVELUP_SWORDSMAN = 5697,	//return levelup
PACKET_CG_REQ_MARRAGE 			= 5698,	//Client ask about marrage
PACKET_GC_RET_MARRAGE 			= 5699,	//Server Ret about marrage
PACKET_CG_ASK_CHALLENGEGUILDWAR = 5700,	//Ask ChallengeGuildWar
PACKET_CG_LOCK_SWORDSMAN 		= 5701,	//Client Send LockSwordsMan
PACKET_CG_UNLOCK_SWORDSMAN 		= 5702,	//Client Send UnLockSwordsMan
PACKET_CG_ASK_HUASHANPVP_STATE 	= 5703,	//Request state
PACKET_GC_SYN_LOVERINFO 		= 5704,	//Server Syn Lover Info
PACKET_CG_SNS_INVITE_CODE 		= 5705,	//SNS Invite code
PACKET_GC_SNS_INVITE_CODE_RESPONSE = 5706,	//SNS Invite code response
PACKET_GC_SNS_ACTIVE_SHOW 		= 5707,	//SNS active show
PACKET_CG_SNS_SHARE 			= 5708,	//SNS share ok
PACKET_GC_PUSH_NOTIFICATION 	= 5709,	//server send NoticeData to client
PACKET_CG_ASK_NEWONLINEAWARD 	= 5711,	//client ask to get NewOnlineAward
PACKET_GC_NEWONLINEAWARD_DATA 	= 5712,	//Send NewOnlineAward Data to client
PACKET_GC_SYNC_NEWONLINEAWARDTABLE = 5713,	//Server send OnlineAwardTable to Client
PACKET_CG_GUILD_INVITE 			= 5716,	//Invite Player Join Main Player's Guild
PACKET_GC_GUILD_INVITE_CONFIRM 	= 5717,	//receive Invite Guild Confirm
PACKET_CG_GUILD_INVITE_CONFIRM 	= 5718,	//send Invite Guild Confirm
PACKET_GC_SYNC_PAY_ACTIVITY_DATA = 5719,	//Sync Payment Activity Data
PACKET_CG_ASK_PAY_ACTIVITY_PRIZE = 5720,	//Ask Pay Activity Prize
PACKET_GC_ASK_PAY_ACTIVITY_PRIZE_RET = 5721,	//Ask Pay Activity Prize Ret
PACKET_CG_ASK_LOCK_TITLE 		= 5722,	//Client Ask Lock Title
PACKET_GC_RET_LOCK_TITLE 		= 5723,	//Server Ret Lock Title
PACKET_CG_REQUEST_CDKEY 		= 5724, 	//Client Use CDKey
PACKET_CG_REQ_CHANGENAME 		= 5733,	//Req_ChangeName
PACKET_GC_RET_CHANGENAME		= 5734,	//Ret_ChangeName
PACKET_GC_WORLDBOSS_SOMECHALL_ME = 5735,	//answer_WORLDBOSS_Challenge
PACKET_CG_WORLDBOSS_CHALL_RESPONSE = 5736,	//response battle
PACKET_GC_SYNC_MASTER_SKILL_NAME = 5737,	//Sync Master Skill Name
PACKET_GC_SYNC_COPYSCENEEXTRANUMBER = 5738,	//Sync CopySceneExtraNumber to Client
PACKET_GC_CHANGENAME 			= 5739,	//ChangeName



PACKET_GC_WORLDBOSS_CHALLEGE_RES = 5745,	//worldboss challenge
PACKET_CG_REQ_HUASHAN_PKINFO 	= 5746,	//HuaShan PK Info  request
PACKET_GC_RET_HUASHAN_PKINFO 	= 5747,	//HuaShan PKInfo
PACKET_GC_PLAY_YANHUA 			= 5748,	//YanHua
PACKET_GC_CREATE_YANHUA 		= 5749,	//Create YanHuaObj
PACKET_CG_ASK_TRAIL 			= 5753,	//Client Ask Trail Player
PACKET_GC_RET_TRAIL 			= 5754,	//Server Ret Trail Player
PACKET_GC_UPDATE_DEF_TITLE 		= 5756,	//Update Def Title

PACKET_CG_GUILD_JOIN_OTHERPLAYER = 5758,	//Guild Client Req Join OtherPlayer Guild
PACKET_GC_OPEN_SHAREWINDOW 		= 5759,	//server send OpenShareWindow to client
PACKET_CG_MASTERSHOP_BUY 		= 5760,	//Client Buy MasterShop Goods
PACKET_GC_MASTERSHOP_BUY 		= 5761,	//Server Send Buy MasterShop Goods Result
PACKET_GC_UPDATE_RECHARGESTATE 	= 5762,	//server send isenable recharge
PACKET_CG_ASK_ISRECHARGE_ENABLE = 5763,	//client req is reacharge enable
PACKET_CG_ASK_GUILDWILDWAR 		= 5764,	//Ask GuildWildWar
PACKET_CG_ASK_ENEMYGUILDINFO 	= 5765,	//Ask Enemy Guild Info
PACKET_GC_RET_ENEMYGUILDINFO 	= 5766,	//Ret Enemy Guild Info
PACKET_GC_RET_ISWILDENEMY2USER 	= 5767,	//IsEnemy2User
PACKET_GC_RESTAURANT_VISITFRIENDINFO = 5768,	//server send visit friend info
PACKET_GC_SHOWPKNOTICE 			= 5769,	//show PK Notice
PACKET_GC_GUILDACTIVITY_BOSSDATA = 5770,	//Update GuildActivity UI
PACKET_CG_ASK_NEW7DAYONLINEAWARD = 5771,	//client ask to get New7DayOnlineAward
PACKET_GC_NEW7DAYONLINEAWARD_DATA = 5772,	//Send New7DayOnlineAward Data to client
PACKET_GC_SYNC_NEW7DAYONLINEAWARDTABLE = 5773,	//Server send New7DayOnlineAwardTable to Client
PACKET_GC_SERVERFLAGS 			= 5774,	//Server send flags when client login
PACKET_CG_ASK_SPECIALAWARD 		= 5775,	//Client Ask For SpecialAward
PACKET_GC_TODAY_FIRST_LOGIN 	= 5776,	//Server Send Today First Login 




PACKET_CG_HUASHAN_PVP_REGISTER 		= 5889,	//regiser for HUASHAN PvP
PACKET_CG_HUASHAN_PVP_MEMBERLIST 	=5890,	//HuaShan PvP Member list request
PACKET_GC_HUASHAN_PVP_MEMBERLIST 	=5891,	//HuaShan PvP Member list
PACKET_GC_HUASHAN_PVP_STATE 		=5892,	//HuaShan PvP state
PACKET_GC_HUASHAN_PVP_SELFPOSITION 	=5893,	//HuaShan PvP self position
PACKET_GC_HUASHAN_PVP_SHOWSEARCH 	=5894,	//HuaShan PvP search opponent
PACKET_GC_HUASHAN_PVP_OPPONENTVIEW 	=5895,	//HuaShan PvP Opponent View
PACKET_GC_HUASHAN_PVP_ASSIST_STATE 	=5896,	//HuaShan PvP assist disable or enable
PACKET_CG_HUASHAN_ASSIST_REQ 		=5897,	//HuaShan PvP assist request




PACKET_CG_DUEL_REQUEST 		= 6145,	//request duel somebody
PACKET_GC_DUEL_REQUESTU 	= 6146,	//somebody request duel with U
PACKET_CG_DUEL_RESPONSE 	= 6147,	//response duel
PACKET_GC_DUEL_STATE 		= 6148,	//duel state




PACKET_CG_MERCENARY_LIST_REQ 	= 6401,	//request mercenary list
PACKET_GC_MERCENARY_LIST_RES 	= 6402, 	//response mercenary list
PACKET_GC_MERCENARY_LEFTTIMES 	= 6403,	//mercenary left times
PACKET_GC_MERCENARY_EMPLOYLIST 	= 6404,	//response mercenary employed  list
PACKET_CG_MERCENARY_REQ 		= 6405,	//request mercenary



PACKET_GC_RESTAURANT_UPDATE 		= 6657,	// server send restaurant data
PACKET_GC_RESTAURANT_DESTUPDATE 	= 6658,	// server send restaurant desk data
PACKET_GC_RESTAURANT_LEVELUPDATE 	= 6659,	// server send restaurant level data
PACKET_CG_RESTAURANT_PREPAREFOOD 	= 6660,	//client send prepare food data
PACKET_CG_RESTAURANT_BILLINGALL 	= 6661,	//client send billing
PACKET_CG_RESTAURANT_FINISHPREPARE 	= 6662,	//client send finish prepare
PACKET_CG_RESTAURANT_ACTIVEDESK 	= 6663,	//client send active dest
PACKET_CG_RESTAURANT_VISITFRIEND 	= 6664,	//




PACKET_CG_MASTER_REQ_LIST 	= 6913, 	//Client Req All Server Master Info
PACKET_GC_MASTER_RET_LIST 	= 6914,	//Server Ret All Server Master Info
PACKET_CG_MASTER_REQ_INFO 	= 6915,	//Client Req Master Info
PACKET_GC_MASTER_RET_INFO 	= 6916,	//Server Ret Master Info
PACKET_CG_MASTER_REQ_CHANGE_NOTICE = 6917,	//Client Req Change Master Notice
PACKET_CG_MASTER_CREATE 	= 6918,	//Client Req Create Master
PACKET_GC_MASTER_CREATE 	= 6919,	//Server Ret Create Master
PACKET_CG_MASTER_JOIN 		= 6920,	//Client Req Join Master
PACKET_GC_MASTER_JOIN 		= 6921,	//Server Ret Join Master
PACKET_CG_MASTER_LEAVE 		= 6922,	//Client Req Leave Master
PACKET_GC_MASTER_LEAVE 		= 6923,	//Server Ret Leave Master
PACKET_CG_MASTER_KICK 		= 6924,	//Client Req Kick Master
PACKET_GC_MASTER_KICK 		= 6925,	//Server Ret Kick Master
PACKET_CG_MASTER_APPROVE_RESERVE = 6926,	//Client Req Approve Reserve Member
PACKET_GC_MASTER_APPROVE_RESERVE = 6927,	//Server Ret Approve Reserve Member
PACKET_CG_MASTER_ACTIVE_SKILL = 6928,	//Client Req Learn Skill
PACKET_GC_MASTER_LEARN_SKILL = 6929,	//Server Ret Learn Skill
PACKET_CG_MASTER_FORGET_SKILL = 6930,	//Client Req Forget Skill
PACKET_GC_MASTER_FORGET_SKILL = 6931,	//Server Ret Forget Skill
PACKET_CG_MASTER_LEARN_SKILL = 6932,	//Client Req Active Skill
PACKET_GC_MASTER_ACTIVE_SKILL = 6933,	//Server Ret Active Skill







PACKET_GC_UPDATENOTICEDATA,	//server send NoticeData to client
PACKET_GC_SERVER_SERIOUSERROR,	//send server error
PACKET_GC_ADDITIONINFO_UPDATE,	//send addition info
PACKET_CG_RANDOM_OPPONENT,	//request opponent list
PACKET_GC_OPPONENT_LIST,	// opponent list
PACKET_GC_CREATE_ZOMBIEUSER,	//Create zombie user
PACKET_GC_TELEMOVE,	//TeleMove
PACKET_GC_REMOVEEFFECT,	//remove Effect
PACKET_CG_CONSIGNSALEITEM,	//ConsignSale SaleItem
PACKET_CG_CANCELCONSIGNSALEITEM,	//ConsignSale  CancelSaleItem
PACKET_CG_ASK_MYCONSIGNSALEITEM,	//ConsignSale  Ask My ConsignSale Items
PACKET_GC_RET_MYCONSIGNSALEITEM,	//ConsignSale  Ret My ConsignSale Items
PACKET_CG_ASK_CONSIGNSALEITEMINFO,	//ConsignSale  Ask ConsignSale Items
PACKET_GC_RET_CONSIGNSALEITEMINFO,	//ConsignSale  Ret  ConsignSale Items
PACKET_CG_BUY_CONSIGNSALEITEMINFO,	//ConsignSale  buy ConsignSale Item
PACKET_GC_SYNC_COMMONDATA,	//Sync CommonData to Client
PACKET_GC_SYNC_COMMONFLAG,	//Sync CommonFlag to Client
PACKET_CG_ASK_SETCOMMONFLAG,	//Client ask to set Commonflag
PACKET_GC_ASK_COMMONFLAG_RET,	//Sync CommonFlag to Client
PACKET_CG_DAILYLUCKYDRAW_DRAW,	//DailyLuckyDraw  CG_DAILYLUCKYDRAW_DRAW
PACKET_GC_DAILYLUCKYDRAW_GAINBONUS,	//DailyLuckyDraw  GC_DAILYLUCKYDRAW_GAINBONUS
PACKET_GC_DAILYLUCKYDRAW_UPDATE,	//DailyLuckyDraw  GC_DAILYLUCKYDRAW_UPDATE
PACKET_GC_DAILYLUCKYDRAW_FAIL,	//DailyLuckyDraw  GC_DAILYLUCKYDRAW_FAIL
PACKET_GC_SYNC_ACTIVENESS,	//Sync Activeness to Client
PACKET_GC_SEND_FASHIONINFO,	//Server Send Fshion Info
PACKET_GC_SYNC_FASHION,	//Server Sync All Fshion
PACKET_CG_TAKEOFF_FASHION,	//Client Wear Fashion
PACKET_GC_SEND_CURFASHION,	//Server Send Cur FashionID
PACKET_CG_ASK_TEAMPLATFORMINFO,	// Send TeamPlatform to Server
PACKET_GC_RET_TEAMPLATFORMINFO,	// Send TeamPlatform to Client
PACKET_CG_ASK_AUTOTEAM,	// Send AutoTeam to Server
PACKET_GC_RET_AUTOTEAM,	// Send AutoTeam to Client
PACKET_GC_DYNAMICOBSTACLE_OPT,	//Sever commond Create dynamic obstacle
PACKET_CG_BUY_GUILDGOODS,	//Client Buy GuildShop Goods
PACKET_GC_UPDATE_NEEDIMPACTINFO,	//syn need Impact Info

 PACKET_SIZE
 }
