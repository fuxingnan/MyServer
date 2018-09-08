//This code create by CodeEngine, do NOT modify

using System;
public enum MessageID :ushort {
    PACKET_NONE                             = 0,

    //玩家属性处理模块: id = 0, name = attr
    PACKET_CG_GET_REGISTER                  = 1, // 1:获取签到数据
    PACKET_GC_RET_REGISTER                  = 2, // 2:返回签到数据结果
    PACKET_CG_REGISTER                      = 3, // 3:点击签到
    PACKET_GC_REGISTER_RET                  = 4, // 4:签到结果
    PACKET_CG_CHANGE_ATTR                   = 6, // 6:属性改变
    PACKET_GC_CHANGE_RET                    = 7, // 7:属性改变结果
    PACKET_GC_PLAYER_KICKOFF                = 8, // 8:踢掉已经登录的玩家
    PACKET_CG_BIND_ACCOUNT                  = 9, // 9:
    PACKET_GC_BIND_ACCOUNT_RET              = 10, // 10:踢掉已经登录的玩家
    PACKET_GC_GIVE_MONEY                    = 11, // 11:赠送玩家金币
    PACKET_CG_REQ_MONEY                     = 12, // 12:赠送玩家金币

    //账户信息: id = 1, name = acc
    PACKET_CG_LOGIN                         = 257, // 1:用户登录
    PACKET_GC_LOGIN_RET                     = 258, // 2:用户登录返回值
    PACKET_CG_SELECTROLE                    = 259, // 3:选择角色
    PACKET_GC_SELECTROLE_RET                = 260, // 4:选择角色结果
    PACKET_CG_CREATEROLE                    = 261, // 5:创建角色
    PACKET_GC_CREATEROLE_RET                = 262, // 6:创建角色结果
    PACKET_CG_CONNECTED_HEARTBEAT           = 263, // 7:创建角色结果

    //房间信息: id = 2, name = room
    PACKET_CG_JOIN_ROOM                     = 513, // 1:随机匹配加入房间
    PACKET_GC_JOIN_ROOM                     = 514, // 2:随机匹配加入房间
    PACKET_GC_ADD_MEMBER                    = 515, // 3:随机匹配加入房间
    PACKET_CG_ADD_MONEY                     = 516, // 4:随机匹配加入房间
    PACKET_GC_ADD_MONEY                     = 517, // 5:随机匹配加入房间
    PACKET_GC_PLAYER_TURN                   = 518, // 6:随机匹配加入房间
    PACKET_CG_BET_MONEY                     = 519, // 7:随机匹配加入房间
    PACKET_GC_BET_MONEY                     = 520, // 8:随机匹配加入房间
    PACKET_GC_RET_READY                     = 521, // 9:随机匹配加入房间
    PACKET_CG_GET_RANK                      = 522, // 10:随机匹配加入房间
    PACKET_GC_GET_RANK                      = 523, // 11:随机匹配加入房间
    PACKET_CG_QUIT_ROOM                     = 524, // 12:随机匹配加入房间
    PACKET_GC_QUIT_ROOM                     = 525, // 13:随机匹配加入房间
    PACKET_GC_RECONNECT_FAILED              = 526, // 14:随机匹配加入房间
    PACKET_CG_FORCE_JOIN                    = 527, // 15:随机匹配加入房间
    PACKET_GC_FORCE_JOIN                    = 528, // 16:随机匹配加入房间
    PACKET_CG_CHANGE_ROOM                   = 529, // 17:随机匹配加入房间
    PACKET_GC_CHANGE_ROOM                   = 530, // 18:随机匹配加入房间
    PACKET_CG_DELETEROOM                    = 531, // 19:随机匹配加入房间
    PACKET_GC_DELETEROOM                    = 532, // 20:随机匹配加入房间
    PACKET_GC_FRIEND_RESULT                 = 533, // 21:随机匹配加入房间
    PACKET_GC_FRIEND_JOIN_RESULT            = 534, // 22:随机匹配加入房间
    PACKET_GC_GAME_OVER                     = 535, // 23:随机匹配加入房间
    PACKET_GC_HIDE_LOADING                  = 536, // 24:随机匹配加入房间
    PACKET_GC_RANK_WIN_MONEY_VIDEO          = 537, // 25:随机匹配加入房间
    PACKET_CG_GET_VIDEO                     = 538, // 26:随机匹配加入房间
    PACKET_CG_GIVE_ROOM_CARD                = 539, // 27:随机匹配加入房间
    PACKET_GC_GIVE_ROOM_CARD                = 540, // 28:随机匹配加入房间

    //账户信息: id = 3, name = chat
    PACKET_CG_CHAT                          = 769, // 1:聊天
    PACKET_GC_CHAT                          = 770, // 2:聊天
    PACKET_CG_FACE                          = 771, // 3:聊天
    PACKET_GC_FACE                          = 772, // 4:聊天
    PACKET_CG_SOUND                         = 773, // 5:聊天
    PACKET_GC_SOUND                         = 774, // 6:聊天
    PACKET_CG_VOICE                         = 775, // 7:聊天
    PACKET_GC_VOICE                         = 776, // 8:聊天

    //账户信息: id = 4, name = gm
    PACKET_CG_GM_COMMOND                    = 1025, // 1:聊天
    PACKET_GC_GM_COMMOND                    = 1026, // 2:聊天
    PACKET_CG_GM_PLAYER_RECHARGE            = 1027, // 3:聊天
    PACKET_GC_GM_PLAYER_RECHARGE            = 1028, // 4:聊天

    //账户信息: id = 5, name = kenroom
    PACKET_CG_JOIN_KEN_ROOM                 = 1281, // 1:加入填大坑房间
    PACKET_GC_JOIN_KEN_ROOM                 = 1282, // 2:返回加入填大坑房间
    PACKET_GC_ADD_KEN_MEMBER                = 1283, // 3:房间加入新成员
    PACKET_CG_KEN_ADD_MONEY                 = 1284, // 4:准备消息
    PACKET_GC_KEN_ADD_MONEY                 = 1285, // 5:准备返回
    PACKET_GC_KEN_PLAYER_TURN               = 1286, // 6:随机匹配加入房间
    PACKET_CG_KEN_BET_MONEY                 = 1287, // 7:随机匹配加入房间
    PACKET_GC_KEN_BET_MONEY                 = 1288, // 8:随机匹配加入房间
    PACKET_CG_KEN_OPEN_CARD                 = 1289, // 9:随机匹配加入房间
    PACKET_GC_KEN_OPEN_CARD                 = 1290, // 10:随机匹配加入房间

    //Other Messages
    PACKET_GC_CONNECTED_HEARTBEAT          , // server connected heartbeat
    PACKET_GC_NOTICE                       , // notice from server
    PACKET_CG_REQ_RANDOMNAME               , // Client Request Random Name
    PACKET_GC_RET_RANDOMNAME               , // Server ret randomname
    PACKET_GC_ENTER_SCENE                  , // Enter Scene
    PACKET_CG_ENTER_SCENE_OK               , // Client Enter Scene OK
    PACKET_CG_REQ_CHANGE_SCENE             , // Request Change Scene
    PACKET_GC_CREATE_PLAYER                , // Create Player
    PACKET_GC_DELETE_OBJ                   , // Delete Player
    PACKET_CG_SYNC_POS                     , // Sync Position to Client
    PACKET_GC_SYNC_POS                     , // Sync Position to Server
    PACKET_CG_MOVE                         , // Player Move
    PACKET_GC_MOVE                         , // Notify Character Move
    PACKET_GC_STOP                         , // Notify Character Stop
    PACKET_CG_REQ_NEAR_LIST                , // client require nearby player list
    PACKET_GC_NEAR_PLAYERLIST              , // server send nearby player list to client
    PACKET_GC_NEAR_TEAMLIST                , // server send nearby team list to client
    PACKET_GC_CREATE_NPC                   , // Create npc
    PACKET_GC_PLAYSTORY                    , // send client playstory
    PACKET_CG_PLAYSTORY_OVER               , // send server playstory over
    PACKET_CG_ASK_RELIVE                   , // send Ask Relive
    PACKET_GC_RET_RELIVE                   , // send Ret Relive
    PACKET_GC_DROPITEM_INFO                , // send DropInfo
    PACKET_CG_ASK_PICKUP_ITEM              , // send Ask PickupItem
    PACKET_GC_RET_PICKUP_ITEM              , // send ret Pickup Item
    PACKET_CG_ASK_SELOBJ_INFO              , // ask current select obj Info
    PACKET_GC_RET_SELOBJ_INFO              , // send ret current select obj Info
    PACKET_GC_DAMAGEBOARD_INFO             , // Send DamageBoard Info to client
    PACKET_CG_OPEN_COPYSCENE               , // Send Open CopyScene Req to Server
    PACKET_GC_COPYSCENE_INVITE             , // Send CopyScene Invite Req to Client
    PACKET_CG_COPYSCENE_INVITE_RET         , // Send CopyScene Invite Ret to Server
    PACKET_GC_COPYSCENE_RESULT             , // Send CopySceneResult to client
    PACKET_CG_ASK_COPYSCENE_REWARD         , // Send CopySceneReward to Server
    PACKET_GC_RET_COPYSCENE_REWARD         , // Send CopySceneReward to Client
    PACKET_CG_ASK_COPYSCENE_SWEEP          , // Send CopySceneSweep to Server
    PACKET_GC_RET_COPYSCENE_SWEEP          , // Send CopySceneSweep to Client
    PACKET_GC_PLAY_EFFECT                  , // Server Send Player Use Tool
    PACKET_GC_OP_TELEPORT                  , // Server Op CopyScene Teleport
    PACKET_GC_OP_QINGGONGPOINT             , // Server Op CopyScene QingGongPoint
    PACKET_GC_SCENE_TIMESCALE              , //  Server Change Scene Time Scale
    PACKET_CG_LEAVE_COPYSCENE              , //  Client Leave Copyscene
    PACKET_GC_UPDATE_ANIMATION_STATE       , // Update Animation state
    PACKET_CG_CHANGE_MAJORCITY             , // Request Change Major City
    PACKET_CG_ASK_QUIT_GAME                , // Ask Change Game Selece Scene
    PACKET_GC_RET_QUIT_GAME                , // Ret Change Game Selece
    PACKET_GC_SYNC_REACHEDSCENE            , // Send Reached Scene
    PACKET_GC_FORCE_SETPOS                 , // Server Force Set Player Pos
    PACKET_GC_DEBUG_MY_POS                 , // Server Debug Player Pos
    PACKET_CG_COMBATVALUE_ASK              , // Client Ask Player CombatValue From Server
    PACKET_GC_COMBATVALUE_RET              , // Server Send Player CombatValue To Client
    PACKET_CG_ASK_PKINFO                   , // Ask PK Info
    PACKET_GC_RET_PKINFO                   , // Ret PK Info
    PACKET_CG_CHANGE_PKMODLE               , // ask change PK Modle
    PACKET_GC_RET_CHANGE_PKMODLE           , // Ret change PK Modle
    PACKET_GC_CHANGE_PKLIST                , //  change PKList
    PACKET_CG_REQ_CHALLENGE                , // request PK somebody
    PACKET_GC_BROADCAST_ATTR               , // Server Broadcast Attr
    PACKET_GC_SYN_ATTR                     , // Server Syn Attr
    PACKET_CG_USER_BEHAVIOR                , // client send behavior
    PACKET_CG_ASK_ROLE_DATA                , // ask role data
    PACKET_GC_RET_ROLE_DATA                , // ret role data
    PACKET_GC_MISSION_SYNC_MISSIONLIST     , // server send mission list to client
    PACKET_CG_ACCEPTMISSION                , // ask to accept mission
    PACKET_GC_ACCEPTMISSION_RET            , // result of accept mission
    PACKET_CG_COMPLETEMISSION              , // ask to complete mission
    PACKET_GC_COMPLETEMISSION_RET          , // result of complete mission
    PACKET_CG_ABANDONMISSION               , // ask to abandon mission
    PACKET_GC_ABANDONMISSION_RET           , // result of abandon mission
    PACKET_GC_MISSION_STATE                , // update mission state
    PACKET_GC_MISSION_PARAM                , // upstate mission param
    PACKET_GC_MISSION_IGNOREMISSIONPREFLAG , // Send ignoremissionpreflag to client
    PACKET_CG_DAILYMISSION_UPDATE          , // Ask to update DailyMission
    PACKET_GC_DAILYMISSION_UPDATE_RET      , // Send DailyMission UpdateData
    PACKET_CG_SKILL_USE                    , // client send use skill
    PACKET_GC_RET_USE_SKILL                , // Use Skill ret
    PACKET_GC_CDTIME_UPDATE                , // Server Update CDTime
    PACKET_GC_SKILL_FINISH                 , //  Server Skill Finish
    PACKET_GC_SKILL_STUDY                  , //  Server Send StudyInfo
    PACKET_GC_SYN_SKILLINFO                , // Server Syn Skill Info
    PACKET_GC_UPDATE_SCENE_INSTACTIVATION  , // Update Scene InstActivation
    PACKET_GC_UPDATE_HITPONIT              , // Update HitPoint
    PACKET_CG_ASK_LEVELUPSKILL             , // Ask LevelUpSkill
    PACKET_GC_ATTACKFLY                    , // Attak fly
    PACKET_GC_UPDATE_ACTIVE_FELLOWSKILL    , // Update Fellow Active Skill
    PACKET_CG_EQUIP_FELLOW_SKILL           , // Equip Fellow Skill
    PACKET_GC_EQUIP_FELLOW_SKILL_RET       , // Equip Fellow Skill Ret
    PACKET_CG_UNEQUIP_FELLOW_SKILL         , // UnEquip Fellow Skill
    PACKET_GC_UNEQUIP_FELLOW_SKILL_RET     , // UnEquip Fellow Skill Ret
    PACKET_CG_LEVELUP_FELLOW_SKILL         , // LevelUp Fellow Skill
    PACKET_GC_LEVELUP_FELLOW_SKILL_RET     , // LevelUp Fellow Skill Ret
    PACKET_CG_GMCOMMAND                    , // send gm command
    PACKET_CG_ASK_LOUDSPEAKER_POOL         , // Client Ask LoudSpeaker Pool
    PACKET_GC_ASK_LOUDSPEAKER_CONTENT      , // Server Ask Client LoudSpeaker Content
    PACKET_CG_ASK_NEWSERVERAWARD           , // client ask to get NewServerAward
    PACKET_GC_NEWSERVERAWARD_DATA          , // Send NewServerAward Data to client
    PACKET_CG_ASK_DAYAWARD                 , // client ask to get DayAward
    PACKET_GC_DAYAWARD_DATA                , // Send DayAward Data to client
    PACKET_CG_ASK_ONLINEAWARD              , // client ask to get OnlineAward
    PACKET_GC_ONLINEAWARD_DATA             , // Send OnlineAward Data to client
    PACKET_CG_ASK_ACTIVENESSAWARD          , // client ask to get ACTIVENESSAWARD
    PACKET_GC_ASK_ACTIVENESSAWARD_RET      , // Send ACTIVENESSAWARD ret to client
    PACKET_GC_SYNC_ACTIVENESSAWARD         , // Sync ACTIVENESSAWARD Data to client
    PACKET_CG_MONEYTREE_ASKAWARD           , // MoneyTree client ask server award
    PACKET_GC_MONEYTREE_DATA               , // Server sync moneytree data to client
    PACKET_GC_BELLE_DATA                   , // server send bell data
    PACKET_CG_BELLE_CLOSE                  , // client send belle close
    PACKET_GC_BELLE_CLOSE_RET              , // server ret belle close
    PACKET_CG_BELLE_EVOLUTION              , // client send belle evolution
    PACKET_GC_BELLE_EVOLUTION_RET          , // server send belle evolution ret
    PACKET_CG_BELLE_EVOLUTIONRAPID         , // client send belle evolution rapid
    PACKET_GC_BELLE_EVOLUTIONRAPID_RET     , // server send belle evolution rapid ret
    PACKET_CG_BELLE_BATTLE                 , // client send belle battle
    PACKET_GC_BELLE_BATTLE_RET             , // server send belle battle ret
    PACKET_CG_BELLE_REST                   , // client send belle rest
    PACKET_GC_BELLE_REST_RET               , // server send belle rest ret
    PACKET_CG_BELLE_ACTIVEMATRIX           , // client send belle Matrix active
    PACKET_GC_BELLE_ACTIVEMATRIX_RET       , // server send belle Matrix Active ret
    PACKET_GC_BELLE_ACTIVE                 , // server send belle Active
    PACKET_CG_ASK_BLACKMARKETITEMINFO      , // Ask BlackMarket Item info
    PACKET_GC_RET_BLACKMARKETITEMINFO      , // Ret BlackMarket Item info
    PACKET_CG_BUY_BLACKMARKETITEM          , // Buy BlackMarket Item
    PACKET_GC_CLOSE_BLACKMARKET            , // Close BlackMarket Item
    PACKET_GC_SHOW_BLACKMARKET             , // Server Show YuanBaoShop BlackMarket
    PACKET_CG_ASK_YUANBAOSHOP_OPEN         , // Client Ask YuanBaoShop Open
    PACKET_CG_BUY_YUANBAOGOODS             , // Client Buy YuanBaoShop Goods
    PACKET_GC_RET_YUANBAOSHOP_OPEN         , // Server Ret YuanBaoShop Open
    PACKET_GC_SERVER_CONFIG                , // server Config
    PACKET_CG_BUY_FASHION                  , // Client Buy Fashion
    PACKET_CG_BUY_STAMINA                  , // Client Buy Stamina
    PACKET_CG_SYSTEMSHOP_BUY               , // client buy from systemshop
    PACKET_CG_SYSTEMSHOP_BUYBACK           , // client buy back from systemshop
    PACKET_CG_SYSTEMSHOP_VIEW              , // client ask view systemshop
    PACKET_CG_WEAR_FASHION                 , // Client Wear Fashion
    PACKET_GC_SYSTEMSHOP_MERCHANDISELIST   , // Server send MerchandiseList to client
    PACKET_CG_GUILD_REQ_LIST               , // Guild Client Req All Server Guild Info
    PACKET_GC_GUILD_RET_LIST               , // Guild Server Ret All Server Guild Info
    PACKET_CG_GUILD_REQ_INFO               , // Guild Client Req Self Guild Info
    PACKET_GC_GUILD_RET_INFO               , // Guild Server Ret Self Guild Info
    PACKET_CG_GUILD_REQ_CHANGE_NOTICE      , // Guild Client Req Change Guild Notice
    PACKET_CG_GUILD_CREATE                 , // Guild Client Req Create Guild
    PACKET_GC_GUILD_CREATE                 , // Guild Server Ret Create Guild
    PACKET_CG_GUILD_JOIN                   , // Guild Client Req Join Guild
    PACKET_GC_GUILD_JOIN                   , // Guild Server Ret Join Guild
    PACKET_CG_GUILD_LEAVE                  , // Guild Client Req Leave Guild
    PACKET_GC_GUILD_LEAVE                  , // Guild Server Ret Leave Guild
    PACKET_CG_GUILD_KICK                   , // Guild Client Req Kick Guild
    PACKET_CG_GUILD_JOB_CHANGE             , // Guild Client Req Change Member Job
    PACKET_CG_GUILD_APPROVE_RESERVE        , // Guild Client Req Approve Reserve Member
    PACKET_CG_GUILD_REQ_LEVELUP            , // Guild Client Req Guild Level Up
    PACKET_GC_GUILD_RET_LEVELUP            , // Guild Server Ret Guild Level Up
    PACKET_GC_UPDATEITEM                   , // 
    PACKET_CG_USE_ITEM                     , // 
    PACKET_GC_USE_ITEM_RET                 , // 
    PACKET_CG_EQUIP_ITEM                   , // 
    PACKET_CG_UNEQUIP_ITEM                 , // 
    PACKET_CG_THROW_ITEM                   , // 
    PACKET_CG_PUT_ITEM_STORAGEPACK         , // 
    PACKET_GC_PUT_ITEM_STORAGEPACK_RET     , // 
    PACKET_CG_TAKE_ITEM_STORAGEPACK        , // 
    PACKET_GC_TAKE_ITEM_STORAGEPACK_RET    , // 
    PACKET_CG_STORAGEPACK_UNLOCK           , // 
    PACKET_CG_BACKPACK_UNLOCK              , // 
    PACKET_GC_BACKPACK_RESIZE              , // 
    PACKET_CG_EQUIP_ENCHANCE               , // 
    PACKET_GC_EQUIP_ENCHANCE_RET           , // 
    PACKET_CG_EQUIP_STAR                   , // 
    PACKET_GC_EQUIP_STAR_RET               , // 
    PACKET_CG_PUT_GEM                      , // 
    PACKET_GC_PUT_GEM_RET                  , // 
    PACKET_CG_TAKE_GEM                     , // 
    PACKET_GC_TAKE_GEM_RET                 , // 
    PACKET_GC_UPDATE_GEM_INFO              , // 
    PACKET_GC_SHOW_USEITEMREMIND           , // 
    PACKET_GC_SHOW_ITEMREMIND              , // 
    PACKET_GC_SHOW_EQUIPREMIND             , // 
    PACKET_CG_ASK_UPDATE_STORAGEPACK       , // 
    PACKET_GC_UPDATE_STORAGEPACK           , // 
    PACKET_GC_ASK_UPDATE_STORAGEPACK_RET   , // 
    PACKET_GC_RET_PUT_GEM                  , // 
    PACKET_CG_SYSTEMSHOP_SELL              , // client sell to systemshop
    PACKET_GC_MAIL_UPDATE                  , // server update mail
    PACKET_GC_MAIL_DELETE                  , // server del mail
    PACKET_CG_MAIL_SEND                    , // client send mail
    PACKET_CG_MAIL_OPERATION               , // client op mail
    PACKET_GC_MOUNTCOLLECTED_FLAG          , // Sync MountCollected flag
    PACKET_GC_MOUNT_DATA                   , // Sync Mount Status
    PACKET_CG_MOUNT_MARK                   , // client send Mount MarkAutoMoutID
    PACKET_GC_MOUNT_MARK_RET               , // server send Mount MarkAutoMoutID ret
    PACKET_CG_MOUNT_MOUNT                  , // client send Mount ride mount
    PACKET_CG_MOUNT_UNMOUNT                , // client send Mount unmount
    PACKET_CG_ADDFRIEND                    , // Client Req Add Friend
    PACKET_GC_ADDFRIEND                    , // Server Ret Add Friend
    PACKET_CG_DELFRIEND                    , // Client Req Del Friend
    PACKET_CG_REQ_FRIEND_USERINFO          , // Client Req Update Friend UserInfo
    PACKET_GC_RET_FRIEND_USERINFO          , // Server Ret Update Friend UserInfo
    PACKET_GC_DELFRIEND                    , // Server Ret Del Friend
    PACKET_GC_NOTICE_ADDED_FRIEND          , // Server Notice Client be added by Other Player
    PACKET_GC_SYC_FRIEND_STATE             , // Server Syc One Friend State
    PACKET_GC_SYC_FRIEND_INFO              , // Server Syc One Friend Info
    PACKET_GC_SYC_FULL_FRIEND_LIST         , // Server Syc Full Friends List
    PACKET_CG_ADDBLACKLIST                 , // Client Req Add BlackList
    PACKET_GC_ADDBLACKLIST                 , // Server Ret Add BlackList
    PACKET_GC_SYC_FULL_BLACK_LIST          , // Server Syc Full Black List
    PACKET_CG_DELBLACKLIST                 , // Client Req Del BlackList
    PACKET_GC_DELBLACKLIST                 , // Server Ret Del BlackList
    PACKET_CG_FINDPLAYER                   , // Client Req Find Player
    PACKET_GC_FINDPLAYER                   , // Server Ret Find Player Result
    PACKET_GC_SYNSELTRAGET_ATTR            , // Server Syn SelectObj Attr
    PACKET_GC_SYC_FULL_HATE_LIST           , // Server Syc Full Hate List
    PACKET_CG_DELHATELIST                  , // Client Req Del HateList
    PACKET_GC_DELHATELIST                  , // Server Ret Del HateList
    PACKET_GC_ADDHATELIST                  , // Server Add Hate List
    PACKET_CG_REQ_TEAM_INVITE              , // client request invite other player join team
    PACKET_CG_REQ_TEAM_JOIN                , // client request join other player team
    PACKET_CG_REQ_TEAM_LEAVE               , // client request leave team
    PACKET_CG_REQ_TEAM_KICK_MEMBER         , // client req kick team member
    PACKET_CG_REQ_TEAM_CHANGE_LEADER       , // client req change leader
    PACKET_GC_TEAM_LEAVE                   , // client leave team
    PACKET_GC_TEAM_SYNC_TEAMINFO           , // server send full team info to client
    PACKET_GC_TEAM_SYNC_MEMBERINFO         , // server send member info to client
    PACKET_GC_JOIN_TEAM_INVITE             , // server send join team invite to client
    PACKET_CG_JOIN_TEAM_INVITE_RESULT      , // client send join team invite result to server
    PACKET_GC_JOIN_TEAM_REQUEST            , // server send join team request to client
    PACKET_CG_JOIN_TEAM_REQUEST_RESULT     , // client send join team request result to server
    PACKET_GC_UPDATE_ALL_TITLEINVESTITIVE  , // Server Update All TitleInvestitive
    PACKET_CG_ACTIVE_TITLE                 , // Client Active Title
    PACKET_CG_DELETE_TITLE                 , // Client Delete Title
    PACKET_GC_GAIN_TITLE                   , // Server Gain Title
    PACKET_GC_DELETE_TITLE                 , // Server Delete Title
    PACKET_GC_ACTIVE_TITLE                 , // Server Active Title
    PACKET_GC_SYNC_ACTIVETITLE             , // Server Active Title
    PACKET_GC_WORLDBOSS_DEAD               , // notify world boss is dead
    PACKET_CG_WORLDBOSS_TEAMLIST_REQ       , // request world boss team list
    PACKET_GC_WORLDBOSS_TEAMLIST           , // world boss team rank list
    PACKET_GC_WORLDBOSS_OPEN               , // world boss is ready
    PACKET_CG_WORLDBOSS_CHALLENGE          , // request challenge boss team
    PACKET_CG_WORLDBOSS_JOIN               , // request kill world boss
    PACKET_GC_UPDATE_FELLOW                , // send update fellow
    PACKET_GC_CREATE_FELLOW                , // Create fellow
    PACKET_CG_CALL_FELLOW                  , // Call Fellow
    PACKET_GC_CALL_FELLOW_RET              , // Call Fellow Ret
    PACKET_CG_UNCALL_FELLOW                , // 
    PACKET_GC_UNCALL_FELLOW_RET            , // UnCall Fellow Ret
    PACKET_CG_LOCK_FELLOW                  , // Lock Fellow
    PACKET_CG_UNLOCK_FELLOW                , // UnLock Fellow
    PACKET_CG_RESOLVE_FELLOW               , // Resolve Fellow
    PACKET_GC_RESOLVE_FELLOW_RET           , // Resolve Fellow Ret
    PACKET_CG_ASK_GAIN_FELLOW              , // Client Ask Gain Fellow
    PACKET_GC_ASK_GAIN_FELLOW_RET          , // Ask Gain Fellow Ret
    PACKET_GC_UPDATE_GAIN_FELLOW_COUNT     , // Update Gain Fellow Count
    PACKET_CG_FELLOW_STAR                  , // Fellow Star
    PACKET_GC_FELLOW_STAR_RET              , // Fellow Star Ret
    PACKET_CG_FELLOW_ENCHANCE              , // Fellow Enchance
    PACKET_GC_FELLOW_ENCHANCE_RET          , // Fellow Enchance Ret
    PACKET_CG_FELLOW_APPLY_POINT           , // Fellow Apply Point
    PACKET_GC_FELLOW_APPLY_POINT_RET       , // Fellow Apply Point Ret
    PACKET_CG_ASK_GAIN_10_FELLOW           , // Client Ask Gain 10 Fellow
    PACKET_GC_ASK_GAIN_10_FELLOW_RET       , // Ask Gain 10 Fellow Ret
    PACKET_CG_FELLOW_CHANGE_NAME           , // client send change fellow name
    PACKET_GC_FELLOW_CHANGE_NAME_RET       , // client send change fellow name ret
    PACKET_GC_CHALLENGE_MYDATA             , // challenge rank's data
    PACKET_CG_CHALLENGERANKLIST_REQ        , // request challenge rank list
    PACKET_GC_CHALLENGERANKLIST            , //  challenge rank list
    PACKET_GC_CHALLENGE_REWARD             , // Challenge rank reward
    PACKET_GC_CHALLENGE_HISTORY            , // Challenge history
    PACKET_CG_ASK_RANK                     , //  Ask Rank To Server
    PACKET_GC_RET_RANK                     , //  Ret Rank to Client
    PACKET_GC_UI_NEWPLAYERGUIDE            , //  Server Send Client NewPlayerGuide
    PACKET_GC_PLAY_MODELSOTRY              , // Server Send Client 3D Story
    PACKET_GC_PLAYSHANDIANLIANEFFECT       , // shandianlian Effect
    PACKET_GC_UI_OPERATION                 , //  ui operation
    PACKET_GC_COUNTDOWN                    , // show countdown
    PACKET_GC_USERTIP                      , // Server Send Client Tip
    PACKET_GC_PLAY_SOUNDS                  , // Server PlaySounds
    PACKET_CG_SCENE_CHANGEINST             , // client send change channle request
    PACKET_GC_SYNC_COPYSCENENUMBER         , // Sync CopySceneNumber to Client
    PACKET_CG_COPYSCENERESET               , // Sync CopySceneReset to Client
    PACKET_CG_CHANGE_SHOWFASHION           , // Client Change ShowFashion
    PACKET_GC_CHANGE_SHOWFASHION           , // Server Change ShowFashion
    PACKET_CG_USE_LIVINGSKILL              , // Client Use LivingSkill Formula
    PACKET_GC_CREATE_SNARE                 , // Create SnareObj
    PACKET_CG_PRELIMINARY_APPLYGUILDWAR    , // Apply preliminary GuildWar
    PACKET_CG_ASK_PRELIMINARY_WARINFO      , // Ask  preliminary war info
    PACKET_GC_RET_PRELIMINARY_WARINFO      , // Ret preliminary war info
    PACKET_GC_SYN_TORCH_VALUE              , // Syn Torch Value
    PACKET_CG_ASK_TORCH_VALUE              , // Ask Torch Value
    PACKET_GC_ASK_STARTGUILDWAR            , // Ask  Star war
    PACKET_CG_RET_STARTWAR                 , // Ret Star war
    PACKET_GC_SHOW_PRELIMINARY_WARRET      , // Show preliminary war Ret info
    PACKET_CG_QIANKUNDAI_COMBINE           , // Client Combine QianKunDai Formula
    PACKET_GC_QIANKUNDAI_PRODUCT           , // Server Send Combine Product
    PACKET_CG_ACTIVE_FELLOW_SKILL          , // Client Ask Active Fellow Skill
    PACKET_CG_FIGHTGUILDWARPOINT           , // Client Fight GuildWar Point
    PACKET_CG_ASK_FINALGUILDWARGROUPINFO   , // Client Ask FinalGuildWar GroupInfo
    PACKET_CG_ASK_FINALGUILDWARPOINTINFO   , // Client Ask FinalGuildWar PointInfo
    PACKET_GC_RET_FINALGUILDWARGROUPINFO   , // Ret  FinalGuildWar Group Info
    PACKET_GC_RET_FINALGUILDWARPOINTINFO   , // Ret FinalGuildWar Point Info
    PACKET_GC_UPDATE_STAMINA_TIME          , // Server Sync Stamina Remain Time
    PACKET_GC_LOGIN_QUEUE_STATUS           , // login queue status
    PACKET_GC_OPENFUNCTION                 , // Server Open function
    PACKET_CG_ASK_OTHERROLE_DATA           , // client ask other player data
    PACKET_GC_RET_OTHERROLE_DATA           , // server send other plater data to client
    PACKET_CG_ASK_HIDE_FELLOW              , // Client Ask Hide Fellow
    PACKET_CG_ASK_SHOW_FELLOW              , // Client Ask Show Fellow
    PACKET_CG_CYPAY_SUCCESS                , // Client Send pay success
    PACKET_CG_VISIT_SWORDSMAN              , // Client Send  SwordsMan
    PACKET_CG_SWORDSMAN_LEVELUP            , // Client Send  SwordsMan levelup
    PACKET_CG_BUY_SWORDSMAN                , // Client Send  buy SwordsMan
    PACKET_CG_EQUIP_SWORDSMAN              , // Client Send EquipSwordsMan
    PACKET_CG_UNEQUIP_SWORDSMAN            , // Client Send UnEquipSwordsMan
    PACKET_GC_UPDATE_SWORDSMAN             , // Server update SwordsMan
    PACKET_GC_UPDATE_SWORDSMAN_VISITSTATE  , // Server update SwordsManstate
    PACKET_GC_ACTIVITYNOTICE               , // Server send ActivityNotice
    PACKET_CG_FELLOW_RESET_POINT           , // Client Ask Reset Fellow Point
    PACKET_GC_RET_FELLOW_RESET_POINT       , // Server Ret Reset Fellow Point
    PACKET_CG_REQ_POWERUP                  , // Client power up
    PACKET_GC_RES_POWERUP                  , // Server send power up
    PACKET_GC_POWERUP_LIST                 , // Server send power up list
    PACKET_GC_BUY_GUILDGOODS               , // Server Send Buy GuildShop Goods Result
    PACKET_GC_SYNC_AWARDTABLE              , // Server send OnlineAwardTable to Client
    PACKET_GC_GUILD_NEWRESERVE             , // Server send Guild Chief And Vice-Chief that their guild have new reserver member
    PACKET_GC_SHOW_SKILLNAME               , // Server Show Skill Name
    PACKET_CG_ASK_CURGUILDWARTYPE          , // Ask current guidwarType
    PACKET_GC_RET_CURGUILDWARTYPE          , // Ret current guidwarType
    PACKET_CG_SET_DEATH_PUSH               , // set death push flag
    PACKET_GC_SWORDSMANPACK_RESIZE         , // Update SwordsManPack Size
    PACKET_GC_RET_VISIT_SWORDSMAN          , // RET_VISITSWORDSMAN
    PACKET_GC_RET_LEVELUP_SWORDSMAN        , // return levelup
    PACKET_CG_REQ_MARRAGE                  , // Client ask about marrage
    PACKET_GC_RET_MARRAGE                  , // Server Ret about marrage
    PACKET_CG_ASK_CHALLENGEGUILDWAR        , // Ask ChallengeGuildWar
    PACKET_CG_LOCK_SWORDSMAN               , // Client Send LockSwordsMan
    PACKET_CG_UNLOCK_SWORDSMAN             , // Client Send UnLockSwordsMan
    PACKET_CG_ASK_HUASHANPVP_STATE         , // Request state
    PACKET_GC_SYN_LOVERINFO                , // Server Syn Lover Info
    PACKET_CG_SNS_INVITE_CODE              , // SNS Invite code
    PACKET_GC_SNS_INVITE_CODE_RESPONSE     , // SNS Invite code response
    PACKET_GC_SNS_ACTIVE_SHOW              , // SNS active show
    PACKET_CG_SNS_SHARE                    , // SNS share ok
    PACKET_GC_PUSH_NOTIFICATION            , // server send NoticeData to client
    PACKET_CG_ASK_NEWONLINEAWARD           , // client ask to get NewOnlineAward
    PACKET_GC_NEWONLINEAWARD_DATA          , // Send NewOnlineAward Data to client
    PACKET_GC_SYNC_NEWONLINEAWARDTABLE     , // Server send OnlineAwardTable to Client
    PACKET_CG_GUILD_INVITE                 , // Invite Player Join Main Player's Guild
    PACKET_GC_GUILD_INVITE_CONFIRM         , // receive Invite Guild Confirm
    PACKET_CG_GUILD_INVITE_CONFIRM         , // send Invite Guild Confirm
    PACKET_GC_SYNC_PAY_ACTIVITY_DATA       , // Sync Payment Activity Data
    PACKET_CG_ASK_PAY_ACTIVITY_PRIZE       , // Ask Pay Activity Prize
    PACKET_GC_ASK_PAY_ACTIVITY_PRIZE_RET   , // Ask Pay Activity Prize Ret
    PACKET_CG_ASK_LOCK_TITLE               , // Client Ask Lock Title
    PACKET_GC_RET_LOCK_TITLE               , // Server Ret Lock Title
    PACKET_CG_REQUEST_CDKEY                , // Client Use CDKey
    PACKET_CG_REQ_CHANGENAME               , // Req_ChangeName
    PACKET_GC_RET_CHANGENAME               , // Ret_ChangeName
    PACKET_GC_WORLDBOSS_SOMECHALL_ME       , // answer_WORLDBOSS_Challenge
    PACKET_CG_WORLDBOSS_CHALL_RESPONSE     , // response battle
    PACKET_GC_SYNC_MASTER_SKILL_NAME       , // Sync Master Skill Name
    PACKET_GC_SYNC_COPYSCENEEXTRANUMBER    , // Sync CopySceneExtraNumber to Client
    PACKET_GC_CHANGENAME                   , // ChangeName
    PACKET_GC_WORLDBOSS_CHALLEGE_RES       , // worldboss challenge
    PACKET_CG_REQ_HUASHAN_PKINFO           , // HuaShan PK Info  request
    PACKET_GC_RET_HUASHAN_PKINFO           , // HuaShan PKInfo
    PACKET_GC_PLAY_YANHUA                  , // YanHua
    PACKET_GC_CREATE_YANHUA                , // Create YanHuaObj
    PACKET_CG_ASK_TRAIL                    , // Client Ask Trail Player
    PACKET_GC_RET_TRAIL                    , // Server Ret Trail Player
    PACKET_GC_UPDATE_DEF_TITLE             , // Update Def Title
    PACKET_CG_GUILD_JOIN_OTHERPLAYER       , // Guild Client Req Join OtherPlayer Guild
    PACKET_GC_OPEN_SHAREWINDOW             , // server send OpenShareWindow to client
    PACKET_CG_MASTERSHOP_BUY               , // Client Buy MasterShop Goods
    PACKET_GC_MASTERSHOP_BUY               , // Server Send Buy MasterShop Goods Result
    PACKET_GC_UPDATE_RECHARGESTATE         , // server send isenable recharge
    PACKET_CG_ASK_ISRECHARGE_ENABLE        , // client req is reacharge enable
    PACKET_CG_ASK_GUILDWILDWAR             , // Ask GuildWildWar
    PACKET_CG_ASK_ENEMYGUILDINFO           , // Ask Enemy Guild Info
    PACKET_GC_RET_ENEMYGUILDINFO           , // Ret Enemy Guild Info
    PACKET_GC_RET_ISWILDENEMY2USER         , // IsEnemy2User
    PACKET_GC_RESTAURANT_VISITFRIENDINFO   , // server send visit friend info
    PACKET_GC_SHOWPKNOTICE                 , // show PK Notice
    PACKET_GC_GUILDACTIVITY_BOSSDATA       , // Update GuildActivity UI
    PACKET_CG_ASK_NEW7DAYONLINEAWARD       , // client ask to get New7DayOnlineAward
    PACKET_GC_NEW7DAYONLINEAWARD_DATA      , // Send New7DayOnlineAward Data to client
    PACKET_GC_SYNC_NEW7DAYONLINEAWARDTABLE , // Server send New7DayOnlineAwardTable to Client
    PACKET_GC_SERVERFLAGS                  , // Server send flags when client login
    PACKET_CG_ASK_SPECIALAWARD             , // Client Ask For SpecialAward
    PACKET_GC_TODAY_FIRST_LOGIN            , // Server Send Today First Login
    PACKET_CG_HUASHAN_PVP_REGISTER         , // regiser for HUASHAN PvP
    PACKET_CG_HUASHAN_PVP_MEMBERLIST       , // HuaShan PvP Member list request
    PACKET_GC_HUASHAN_PVP_MEMBERLIST       , // HuaShan PvP Member list
    PACKET_GC_HUASHAN_PVP_STATE            , // HuaShan PvP state
    PACKET_GC_HUASHAN_PVP_SELFPOSITION     , // HuaShan PvP self position
    PACKET_GC_HUASHAN_PVP_SHOWSEARCH       , // HuaShan PvP search opponent
    PACKET_GC_HUASHAN_PVP_OPPONENTVIEW     , // HuaShan PvP Opponent View
    PACKET_GC_HUASHAN_PVP_ASSIST_STATE     , // HuaShan PvP assist disable or enable
    PACKET_CG_HUASHAN_ASSIST_REQ           , // HuaShan PvP assist request
    PACKET_CG_DUEL_REQUEST                 , // request duel somebody
    PACKET_GC_DUEL_REQUESTU                , // somebody request duel with U
    PACKET_CG_DUEL_RESPONSE                , // response duel
    PACKET_GC_DUEL_STATE                   , // duel state
    PACKET_CG_MERCENARY_LIST_REQ           , // request mercenary list
    PACKET_GC_MERCENARY_LIST_RES           , // response mercenary list
    PACKET_GC_MERCENARY_LEFTTIMES          , // mercenary left times
    PACKET_GC_MERCENARY_EMPLOYLIST         , // response mercenary employed  list
    PACKET_CG_MERCENARY_REQ                , // request mercenary
    PACKET_GC_RESTAURANT_UPDATE            , //  server send restaurant data
    PACKET_GC_RESTAURANT_DESTUPDATE        , //  server send restaurant desk data
    PACKET_GC_RESTAURANT_LEVELUPDATE       , //  server send restaurant level data
    PACKET_CG_RESTAURANT_PREPAREFOOD       , // client send prepare food data
    PACKET_CG_RESTAURANT_BILLINGALL        , // client send billing
    PACKET_CG_RESTAURANT_FINISHPREPARE     , // client send finish prepare
    PACKET_CG_RESTAURANT_ACTIVEDESK        , // client send active dest
    PACKET_CG_RESTAURANT_VISITFRIEND       , // 
    PACKET_CG_MASTER_REQ_LIST              , // Client Req All Server Master Info
    PACKET_GC_MASTER_RET_LIST              , // Server Ret All Server Master Info
    PACKET_CG_MASTER_REQ_INFO              , // Client Req Master Info
    PACKET_GC_MASTER_RET_INFO              , // Server Ret Master Info
    PACKET_CG_MASTER_REQ_CHANGE_NOTICE     , // Client Req Change Master Notice
    PACKET_CG_MASTER_CREATE                , // Client Req Create Master
    PACKET_GC_MASTER_CREATE                , // Server Ret Create Master
    PACKET_CG_MASTER_JOIN                  , // Client Req Join Master
    PACKET_GC_MASTER_JOIN                  , // Server Ret Join Master
    PACKET_CG_MASTER_LEAVE                 , // Client Req Leave Master
    PACKET_GC_MASTER_LEAVE                 , // Server Ret Leave Master
    PACKET_CG_MASTER_KICK                  , // Client Req Kick Master
    PACKET_GC_MASTER_KICK                  , // Server Ret Kick Master
    PACKET_CG_MASTER_APPROVE_RESERVE       , // Client Req Approve Reserve Member
    PACKET_GC_MASTER_APPROVE_RESERVE       , // Server Ret Approve Reserve Member
    PACKET_CG_MASTER_ACTIVE_SKILL          , // Client Req Learn Skill
    PACKET_GC_MASTER_LEARN_SKILL           , // Server Ret Learn Skill
    PACKET_CG_MASTER_FORGET_SKILL          , // Client Req Forget Skill
    PACKET_GC_MASTER_FORGET_SKILL          , // Server Ret Forget Skill
    PACKET_CG_MASTER_LEARN_SKILL           , // Client Req Active Skill
    PACKET_GC_MASTER_ACTIVE_SKILL          , // Server Ret Active Skill
    PACKET_GC_UPDATENOTICEDATA             , // server send NoticeData to client
    PACKET_GC_SERVER_SERIOUSERROR          , // send server error
    PACKET_GC_ADDITIONINFO_UPDATE          , // send addition info
    PACKET_CG_RANDOM_OPPONENT              , // request opponent list
    PACKET_GC_OPPONENT_LIST                , //  opponent list
    PACKET_GC_CREATE_ZOMBIEUSER            , // Create zombie user
    PACKET_GC_TELEMOVE                     , // TeleMove
    PACKET_GC_REMOVEEFFECT                 , // remove Effect
    PACKET_CG_CONSIGNSALEITEM              , // ConsignSale SaleItem
    PACKET_CG_CANCELCONSIGNSALEITEM        , // ConsignSale  CancelSaleItem
    PACKET_CG_ASK_MYCONSIGNSALEITEM        , // ConsignSale  Ask My ConsignSale Items
    PACKET_GC_RET_MYCONSIGNSALEITEM        , // ConsignSale  Ret My ConsignSale Items
    PACKET_CG_ASK_CONSIGNSALEITEMINFO      , // ConsignSale  Ask ConsignSale Items
    PACKET_GC_RET_CONSIGNSALEITEMINFO      , // ConsignSale  Ret  ConsignSale Items
    PACKET_CG_BUY_CONSIGNSALEITEMINFO      , // ConsignSale  buy ConsignSale Item
    PACKET_GC_SYNC_COMMONDATA              , // Sync CommonData to Client
    PACKET_GC_SYNC_COMMONFLAG              , // Sync CommonFlag to Client
    PACKET_CG_ASK_SETCOMMONFLAG            , // Client ask to set Commonflag
    PACKET_GC_ASK_COMMONFLAG_RET           , // Sync CommonFlag to Client
    PACKET_CG_DAILYLUCKYDRAW_DRAW          , // DailyLuckyDraw  CG_DAILYLUCKYDRAW_DRAW
    PACKET_GC_DAILYLUCKYDRAW_GAINBONUS     , // DailyLuckyDraw  GC_DAILYLUCKYDRAW_GAINBONUS
    PACKET_GC_DAILYLUCKYDRAW_UPDATE        , // DailyLuckyDraw  GC_DAILYLUCKYDRAW_UPDATE
    PACKET_GC_DAILYLUCKYDRAW_FAIL          , // DailyLuckyDraw  GC_DAILYLUCKYDRAW_FAIL
    PACKET_GC_SYNC_ACTIVENESS              , // Sync Activeness to Client
    PACKET_GC_SEND_FASHIONINFO             , // Server Send Fshion Info
    PACKET_GC_SYNC_FASHION                 , // Server Sync All Fshion
    PACKET_CG_TAKEOFF_FASHION              , // Client Wear Fashion
    PACKET_GC_SEND_CURFASHION              , // Server Send Cur FashionID
    PACKET_CG_ASK_TEAMPLATFORMINFO         , //  Send TeamPlatform to Server
    PACKET_GC_RET_TEAMPLATFORMINFO         , //  Send TeamPlatform to Client
    PACKET_CG_ASK_AUTOTEAM                 , //  Send AutoTeam to Server
    PACKET_GC_RET_AUTOTEAM                 , //  Send AutoTeam to Client
    PACKET_GC_DYNAMICOBSTACLE_OPT          , // Sever commond Create dynamic obstacle
    PACKET_CG_BUY_GUILDGOODS               , // Client Buy GuildShop Goods
    PACKET_GC_UPDATE_NEEDIMPACTINFO        , // syn need Impact Info

    PACKET_SIZE
}