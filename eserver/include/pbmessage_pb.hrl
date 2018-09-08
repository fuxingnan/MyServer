-ifndef(CG_LOGIN_PB_H).
-define(CG_LOGIN_PB_H, true).
-record(cg_login, {
    account = erlang:error({required, account})
}).
-endif.

-ifndef(GC_LOGIN_RET_PB_H).
-define(GC_LOGIN_RET_PB_H, true).
-record(gc_login_ret, {
    result = erlang:error({required, result}),
    userid = erlang:error({required, userid}),
    appversion = erlang:error({required, appversion}),
    appurl = erlang:error({required, appurl}),
    playerid = erlang:error({required, playerid}),
    stopserver = erlang:error({required, stopserver})
}).
-endif.

-ifndef(CG_CREATEROLE_PB_H).
-define(CG_CREATEROLE_PB_H, true).
-record(cg_createrole, {
    type = erlang:error({required, type})
}).
-endif.

-ifndef(GC_CREATEROLE_RET_PB_H).
-define(GC_CREATEROLE_RET_PB_H, true).
-record(gc_createrole_ret, {
    result = erlang:error({required, result}),
    playerguid = erlang:error({required, playerguid})
}).
-endif.

-ifndef(CG_CONNECTED_HEARTBEAT_PB_H).
-define(CG_CONNECTED_HEARTBEAT_PB_H, true).
-record(cg_connected_heartbeat, {
    isresponse = erlang:error({required, isresponse})
}).
-endif.

-ifndef(GC_CONNECTED_HEARTBEAT_PB_H).
-define(GC_CONNECTED_HEARTBEAT_PB_H, true).
-record(gc_connected_heartbeat, {
    isresponse = erlang:error({required, isresponse})
}).
-endif.

-ifndef(CG_GET_REGISTER_PB_H).
-define(CG_GET_REGISTER_PB_H, true).
-record(cg_get_register, {
    userinfo = erlang:error({required, userinfo})
}).
-endif.

-ifndef(GC_RET_REGISTER_PB_H).
-define(GC_RET_REGISTER_PB_H, true).
-record(gc_ret_register, {
    user_id = erlang:error({required, user_id}),
    user_money = erlang:error({required, user_money}),
    user_name = erlang:error({required, user_name}),
    user_unit = erlang:error({required, user_unit})
}).
-endif.

-ifndef(CG_REGISTER_PB_H).
-define(CG_REGISTER_PB_H, true).
-record(cg_register, {
    serverversion = erlang:error({required, serverversion})
}).
-endif.

-ifndef(GC_REGISTER_RET_PB_H).
-define(GC_REGISTER_RET_PB_H, true).
-record(gc_register_ret, {
    result = erlang:error({required, result}),
    money = erlang:error({required, money}),
    registernum = erlang:error({required, registernum}),
    serverversion = erlang:error({required, serverversion})
}).
-endif.

-ifndef(CG_CHANGE_ATTR_PB_H).
-define(CG_CHANGE_ATTR_PB_H, true).
-record(cg_change_attr, {
    serverversion = erlang:error({required, serverversion}),
    money = erlang:error({required, money}),
    level = erlang:error({required, level}),
    score = erlang:error({required, score})
}).
-endif.

-ifndef(GC_CHANGE_RET_PB_H).
-define(GC_CHANGE_RET_PB_H, true).
-record(gc_change_ret, {
    result = erlang:error({required, result}),
    serverversion = erlang:error({required, serverversion}),
    money = erlang:error({required, money}),
    level = erlang:error({required, level}),
    score = erlang:error({required, score})
}).
-endif.

-ifndef(CG_REQ_MONEY_PB_H).
-define(CG_REQ_MONEY_PB_H, true).
-record(cg_req_money, {
    usr_id = erlang:error({required, usr_id}),
    name = erlang:error({required, name}),
    image_url = erlang:error({required, image_url})
}).
-endif.

-ifndef(GC_GIVE_MONEY_PB_H).
-define(GC_GIVE_MONEY_PB_H, true).
-record(gc_give_money, {
    usr_id = erlang:error({required, usr_id}),
    money = erlang:error({required, money}),
    room_type = erlang:error({required, room_type}),
    addmoney = erlang:error({required, addmoney}),
    firstmoney = erlang:error({required, firstmoney}),
    firstrank = erlang:error({required, firstrank}),
    moneyrank = erlang:error({required, moneyrank}),
    losemoney = erlang:error({required, losemoney}),
    loserank = erlang:error({required, loserank}),
    times = erlang:error({required, times}),
    reconnect = erlang:error({required, reconnect}),
    table_money = erlang:error({required, table_money}),
    room_card = erlang:error({required, room_card}),
    unit_id = erlang:error({required, unit_id})
}).
-endif.

-ifndef(CG_GIVE_ROOM_CARD_PB_H).
-define(CG_GIVE_ROOM_CARD_PB_H, true).
-record(cg_give_room_card, {
    usr_id = erlang:error({required, usr_id}),
    giveplayerid = erlang:error({required, giveplayerid}),
    givecardnum = erlang:error({required, givecardnum}),
    unit_id = erlang:error({required, unit_id})
}).
-endif.

-ifndef(GC_GIVE_ROOM_CARD_PB_H).
-define(GC_GIVE_ROOM_CARD_PB_H, true).
-record(gc_give_room_card, {
    usr_id = erlang:error({required, usr_id}),
    senderid = erlang:error({required, senderid}),
    giveplayerid = erlang:error({required, giveplayerid}),
    sendcardnum = erlang:error({required, sendcardnum}),
    givecardnum = erlang:error({required, givecardnum}),
    unit_id = erlang:error({required, unit_id})
}).
-endif.

-ifndef(CG_JOIN_ROOM_PB_H).
-define(CG_JOIN_ROOM_PB_H, true).
-record(cg_join_room, {
    usr_id = erlang:error({required, usr_id}),
    room_type = erlang:error({required, room_type}),
    room_key,
    min_money,
    max_bet,
    is_double,
    game_time,
    card_num,
    unit_id = erlang:error({required, unit_id})
}).
-endif.

-ifndef(CG_JOIN_HOLE_ROOM_PB_H).
-define(CG_JOIN_HOLE_ROOM_PB_H, true).
-record(cg_join_hole_room, {
    usr_id = erlang:error({required, usr_id}),
    room_type = erlang:error({required, room_type}),
    room_key,
    min_money,
    max_bet,
    is_double,
    unit_id = erlang:error({required, unit_id})
}).
-endif.

-ifndef(GC_JOIN_ROOM_PB_H).
-define(GC_JOIN_ROOM_PB_H, true).
-record(gc_join_room, {
    result = erlang:error({required, result}),
    usr_id,
    room_id,
    room_type,
    leader_id,
    room_key,
    my_pos,
    cur_pos,
    table_money,
    cardone,
    cardtwo,
    min_money,
    max_bet,
    is_double,
    game_time,
    card_num,
    name_list = [],
    head_list = [],
    pos_list = [],
    state_list = [],
    money_list = [],
    unit_id = erlang:error({required, unit_id}),
    cardnum = erlang:error({required, cardnum})
}).
-endif.

-ifndef(CG_GET_VIDEO_PB_H).
-define(CG_GET_VIDEO_PB_H, true).
-record(cg_get_video, {
    usr_id = erlang:error({required, usr_id}),
    player_id = erlang:error({required, player_id}),
    type = erlang:error({required, type}),
    unit_id = erlang:error({required, unit_id})
}).
-endif.

-ifndef(GC_RANK_WIN_MONEY_VIDEO_PB_H).
-define(GC_RANK_WIN_MONEY_VIDEO_PB_H, true).
-record(gc_rank_win_money_video, {
    usr_id,
    my_pos,
    table_money,
    video_money,
    cardone,
    cardtwo,
    name_list = [],
    head_list = [],
    pos_list = [],
    money_list = [],
    unit_id = erlang:error({required, unit_id}),
    cardnum = erlang:error({required, cardnum})
}).
-endif.

-ifndef(GC_ADD_MEMBER_PB_H).
-define(GC_ADD_MEMBER_PB_H, true).
-record(gc_add_member, {
    usr_id = erlang:error({required, usr_id}),
    name = erlang:error({required, name}),
    head = erlang:error({required, head}),
    pos = erlang:error({required, pos}),
    state = erlang:error({required, state}),
    money = erlang:error({required, money}),
    unit_id = erlang:error({required, unit_id})
}).
-endif.

-ifndef(CG_ADD_MONEY_PB_H).
-define(CG_ADD_MONEY_PB_H, true).
-record(cg_add_money, {
    usr_id = erlang:error({required, usr_id}),
    roomtype = erlang:error({required, roomtype}),
    unit_id = erlang:error({required, unit_id})
}).
-endif.

-ifndef(GC_ADD_MONEY_PB_H).
-define(GC_ADD_MONEY_PB_H, true).
-record(gc_add_money, {
    usr_id = erlang:error({required, usr_id}),
    pos = erlang:error({required, pos}),
    unit_id = erlang:error({required, unit_id})
}).
-endif.

-ifndef(GC_PLAYER_TURN_PB_H).
-define(GC_PLAYER_TURN_PB_H, true).
-record(gc_player_turn, {
    usr_id = erlang:error({required, usr_id}),
    pos = erlang:error({required, pos}),
    cardone = erlang:error({required, cardone}),
    cardtwo = erlang:error({required, cardtwo}),
    cardnum = erlang:error({required, cardnum}),
    money = erlang:error({required, money}),
    table_money = erlang:error({required, table_money}),
    left_time,
    isfresh_card = erlang:error({required, isfresh_card}),
    unit_id = erlang:error({required, unit_id})
}).
-endif.

-ifndef(CG_BET_MONEY_PB_H).
-define(CG_BET_MONEY_PB_H, true).
-record(cg_bet_money, {
    usr_id = erlang:error({required, usr_id}),
    money = erlang:error({required, money}),
    one_chip_num = erlang:error({required, one_chip_num}),
    two_chip_num = erlang:error({required, two_chip_num}),
    three_chip_num = erlang:error({required, three_chip_num}),
    four_chip_num = erlang:error({required, four_chip_num}),
    five_chip_num = erlang:error({required, five_chip_num}),
    unit_id = erlang:error({required, unit_id})
}).
-endif.

-ifndef(GC_BET_MONEY_PB_H).
-define(GC_BET_MONEY_PB_H, true).
-record(gc_bet_money, {
    usr_id = erlang:error({required, usr_id}),
    pos = erlang:error({required, pos}),
    cardres = erlang:error({required, cardres}),
    result = erlang:error({required, result}),
    rank_money,
    rank_win_money,
    rank_lose_money,
    curmoney = erlang:error({required, curmoney}),
    betmoney = erlang:error({required, betmoney}),
    tablemoney = erlang:error({required, tablemoney}),
    one_chip_num = erlang:error({required, one_chip_num}),
    two_chip_num = erlang:error({required, two_chip_num}),
    three_chip_num = erlang:error({required, three_chip_num}),
    four_chip_num = erlang:error({required, four_chip_num}),
    five_chip_num = erlang:error({required, five_chip_num}),
    double_lose_num,
    unit_id = erlang:error({required, unit_id})
}).
-endif.

-ifndef(GC_RET_READY_PB_H).
-define(GC_RET_READY_PB_H, true).
-record(gc_ret_ready, {
    usr_id = erlang:error({required, usr_id}),
    unit_id = erlang:error({required, unit_id})
}).
-endif.

-ifndef(CG_GET_RANK_PB_H).
-define(CG_GET_RANK_PB_H, true).
-record(cg_get_rank, {
    usr_id = erlang:error({required, usr_id}),
    type = erlang:error({required, type}),
    unit_id = erlang:error({required, unit_id})
}).
-endif.

-ifndef(GC_GET_RANK_PB_H).
-define(GC_GET_RANK_PB_H, true).
-record(gc_get_rank, {
    usr_id = erlang:error({required, usr_id}),
    type = erlang:error({required, type}),
    name_list = [],
    head_list = [],
    money_list = [],
    cardone_list = [],
    cardtwo_list = [],
    id_list = [],
    unit_id = erlang:error({required, unit_id})
}).
-endif.

-ifndef(CG_QUIT_ROOM_PB_H).
-define(CG_QUIT_ROOM_PB_H, true).
-record(cg_quit_room, {
    usr_id = erlang:error({required, usr_id}),
    type = erlang:error({required, type}),
    unit_id = erlang:error({required, unit_id})
}).
-endif.

-ifndef(GC_QUIT_ROOM_PB_H).
-define(GC_QUIT_ROOM_PB_H, true).
-record(gc_quit_room, {
    usr_id = erlang:error({required, usr_id}),
    pos = erlang:error({required, pos}),
    type = erlang:error({required, type}),
    unit_id = erlang:error({required, unit_id})
}).
-endif.

-ifndef(GC_RECONNECT_FAILED_PB_H).
-define(GC_RECONNECT_FAILED_PB_H, true).
-record(gc_reconnect_failed, {
    usr_id = erlang:error({required, usr_id})
}).
-endif.

-ifndef(CG_CHAT_PB_H).
-define(CG_CHAT_PB_H, true).
-record(cg_chat, {
    usr_id = erlang:error({required, usr_id}),
    content = erlang:error({required, content}),
    unit_id = erlang:error({required, unit_id})
}).
-endif.

-ifndef(GC_CHAT_PB_H).
-define(GC_CHAT_PB_H, true).
-record(gc_chat, {
    usr_id = erlang:error({required, usr_id}),
    pos = erlang:error({required, pos}),
    content = erlang:error({required, content}),
    unit_id = erlang:error({required, unit_id})
}).
-endif.

-ifndef(CG_FACE_PB_H).
-define(CG_FACE_PB_H, true).
-record(cg_face, {
    usr_id = erlang:error({required, usr_id}),
    id = erlang:error({required, id}),
    unit_id = erlang:error({required, unit_id})
}).
-endif.

-ifndef(GC_FACE_PB_H).
-define(GC_FACE_PB_H, true).
-record(gc_face, {
    usr_id = erlang:error({required, usr_id}),
    pos = erlang:error({required, pos}),
    id = erlang:error({required, id}),
    unit_id = erlang:error({required, unit_id})
}).
-endif.

-ifndef(CG_SOUND_PB_H).
-define(CG_SOUND_PB_H, true).
-record(cg_sound, {
    usr_id = erlang:error({required, usr_id}),
    id = erlang:error({required, id}),
    unit_id = erlang:error({required, unit_id})
}).
-endif.

-ifndef(GC_SOUND_PB_H).
-define(GC_SOUND_PB_H, true).
-record(gc_sound, {
    usr_id = erlang:error({required, usr_id}),
    pos = erlang:error({required, pos}),
    id = erlang:error({required, id}),
    unit_id = erlang:error({required, unit_id})
}).
-endif.

-ifndef(CG_VOICE_PB_H).
-define(CG_VOICE_PB_H, true).
-record(cg_voice, {
    usr_id = erlang:error({required, usr_id}),
    id = erlang:error({required, id}),
    unit_id = erlang:error({required, unit_id})
}).
-endif.

-ifndef(GC_VOICE_PB_H).
-define(GC_VOICE_PB_H, true).
-record(gc_voice, {
    usr_id = erlang:error({required, usr_id}),
    pos = erlang:error({required, pos}),
    id = erlang:error({required, id}),
    unit_id = erlang:error({required, unit_id})
}).
-endif.

-ifndef(CG_DELETEROOM_PB_H).
-define(CG_DELETEROOM_PB_H, true).
-record(cg_deleteroom, {
    room_id = erlang:error({required, room_id})
}).
-endif.

-ifndef(GC_DELETEROOM_PB_H).
-define(GC_DELETEROOM_PB_H, true).
-record(gc_deleteroom, {
    result = erlang:error({required, result})
}).
-endif.

-ifndef(GC_FRIEND_RESULT_PB_H).
-define(GC_FRIEND_RESULT_PB_H, true).
-record(gc_friend_result, {
    result = erlang:error({required, result})
}).
-endif.

-ifndef(GC_FRIEND_JOIN_RESULT_PB_H).
-define(GC_FRIEND_JOIN_RESULT_PB_H, true).
-record(gc_friend_join_result, {
    usr_id = erlang:error({required, usr_id}),
    result = erlang:error({required, result}),
    unit_id = erlang:error({required, unit_id})
}).
-endif.

-ifndef(CG_FORCE_JOIN_PB_H).
-define(CG_FORCE_JOIN_PB_H, true).
-record(cg_force_join, {
    usr_id = erlang:error({required, usr_id}),
    unit_id = erlang:error({required, unit_id})
}).
-endif.

-ifndef(GC_GAME_OVER_PB_H).
-define(GC_GAME_OVER_PB_H, true).
-record(gc_game_over, {
    usr_id = erlang:error({required, usr_id}),
    name_list = [],
    head_list = [],
    pos_list = [],
    state_list = [],
    money_list = [],
    unit_id = erlang:error({required, unit_id})
}).
-endif.

-ifndef(GC_HIDE_LOADING_PB_H).
-define(GC_HIDE_LOADING_PB_H, true).
-record(gc_hide_loading, {
    result = erlang:error({required, result})
}).
-endif.

-ifndef(GC_FORCE_JOIN_PB_H).
-define(GC_FORCE_JOIN_PB_H, true).
-record(gc_force_join, {
    usr_id = erlang:error({required, usr_id}),
    paymoney = erlang:error({required, paymoney}),
    curmoney = erlang:error({required, curmoney}),
    pos = erlang:error({required, pos}),
    unit_id = erlang:error({required, unit_id})
}).
-endif.

-ifndef(CG_CHANGE_ROOM_PB_H).
-define(CG_CHANGE_ROOM_PB_H, true).
-record(cg_change_room, {
    usr_id = erlang:error({required, usr_id}),
    unit_id = erlang:error({required, unit_id})
}).
-endif.

-ifndef(GC_CHANGE_ROOM_PB_H).
-define(GC_CHANGE_ROOM_PB_H, true).
-record(gc_change_room, {
    usr_id = erlang:error({required, usr_id}),
    result = erlang:error({required, result}),
    unit_id = erlang:error({required, unit_id})
}).
-endif.

-ifndef(CG_SELECTROLE_PB_H).
-define(CG_SELECTROLE_PB_H, true).
-record(cg_selectrole, {
    roleguid = erlang:error({required, roleguid})
}).
-endif.

-ifndef(GC_SELECTROLE_RET_PB_H).
-define(GC_SELECTROLE_RET_PB_H, true).
-record(gc_selectrole_ret, {
    result = erlang:error({required, result}),
    playerguid = erlang:error({required, playerguid})
}).
-endif.

-ifndef(CG_BIND_ACCOUNT_PB_H).
-define(CG_BIND_ACCOUNT_PB_H, true).
-record(cg_bind_account, {
    serverversion = erlang:error({required, serverversion}),
    facebookuserid = erlang:error({required, facebookuserid})
}).
-endif.

-ifndef(GC_BIND_ACCOUNT_RET_PB_H).
-define(GC_BIND_ACCOUNT_RET_PB_H, true).
-record(gc_bind_account_ret, {
    serverversion = erlang:error({required, serverversion}),
    result = erlang:error({required, result})
}).
-endif.

-ifndef(GC_PLAYER_KICKOFF_PB_H).
-define(GC_PLAYER_KICKOFF_PB_H, true).
-record(gc_player_kickoff, {
    serverversion = erlang:error({required, serverversion})
}).
-endif.

-ifndef(CG_GM_COMMOND_PB_H).
-define(CG_GM_COMMOND_PB_H, true).
-record(cg_gm_commond, {
    content
}).
-endif.

-ifndef(GC_GM_COMMOND_PB_H).
-define(GC_GM_COMMOND_PB_H, true).
-record(gc_gm_commond, {
    online_num = erlang:error({required, online_num}),
    new_room_num = erlang:error({required, new_room_num}),
    ordinary_num = erlang:error({required, ordinary_num}),
    master_num = erlang:error({required, master_num}),
    friend_num = erlang:error({required, friend_num}),
    recharge_num
}).
-endif.

-ifndef(CG_GM_PLAYER_RECHARGE_PB_H).
-define(CG_GM_PLAYER_RECHARGE_PB_H, true).
-record(cg_gm_player_recharge, {
    account = erlang:error({required, account})
}).
-endif.

-ifndef(GC_GM_PLAYER_RECHARGE_PB_H).
-define(GC_GM_PLAYER_RECHARGE_PB_H, true).
-record(gc_gm_player_recharge, {
    recharge_num = erlang:error({required, recharge_num}),
    get_chips = erlang:error({required, get_chips})
}).
-endif.

-ifndef(CG_JOIN_KEN_ROOM_PB_H).
-define(CG_JOIN_KEN_ROOM_PB_H, true).
-record(cg_join_ken_room, {
    usr_id = erlang:error({required, usr_id}),
    room_type = erlang:error({required, room_type}),
    room_key,
    person_num,
    min_poker,
    every_bet,
    max_bet,
    last_is_boom,
    is_double,
    min_money,
    game_times,
    need_card,
    unit_id = erlang:error({required, unit_id})
}).
-endif.

-ifndef(GC_JOIN_KEN_ROOM_PB_H).
-define(GC_JOIN_KEN_ROOM_PB_H, true).
-record(gc_join_ken_room, {
    usr_id = erlang:error({required, usr_id}),
    room_key,
    room_type,
    person_num,
    min_poker,
    every_bet,
    max_bet,
    last_is_boom,
    is_double,
    min_money,
    game_times,
    my_pos,
    cur_pos,
    cur_state,
    table_money,
    card_num,
    room_state,
    room_step,
    name_list = [],
    head_list = [],
    pos_list = [],
    state_list = [],
    state_list1 = [],
    money_list = [],
    poker_list1 = [],
    poker_list2 = [],
    poker_list3 = [],
    poker_list4 = [],
    poker_list5 = [],
    poker1 = erlang:error({required, poker1}),
    poker2 = erlang:error({required, poker2}),
    open_list = [],
    left_game_time,
    over_time = erlang:error({required, over_time}),
    unit_id = erlang:error({required, unit_id})
}).
-endif.

-ifndef(GC_ADD_KEN_MEMBER_PB_H).
-define(GC_ADD_KEN_MEMBER_PB_H, true).
-record(gc_add_ken_member, {
    name = erlang:error({required, name}),
    head = erlang:error({required, head}),
    pos = erlang:error({required, pos}),
    state = erlang:error({required, state}),
    state1 = erlang:error({required, state1}),
    money = erlang:error({required, money}),
    poker3 = erlang:error({required, poker3}),
    poker4 = erlang:error({required, poker4}),
    poker5 = erlang:error({required, poker5})
}).
-endif.

-ifndef(CG_KEN_ADD_MONEY_PB_H).
-define(CG_KEN_ADD_MONEY_PB_H, true).
-record(cg_ken_add_money, {
    roomtype = erlang:error({required, roomtype})
}).
-endif.

-ifndef(GC_KEN_ADD_MONEY_PB_H).
-define(GC_KEN_ADD_MONEY_PB_H, true).
-record(gc_ken_add_money, {
    pos = erlang:error({required, pos})
}).
-endif.

-ifndef(GC_KEN_PLAYER_TURN_PB_H).
-define(GC_KEN_PLAYER_TURN_PB_H, true).
-record(gc_ken_player_turn, {
    cur_pos = erlang:error({required, cur_pos}),
    cur_state = erlang:error({required, cur_state}),
    table_money = erlang:error({required, table_money}),
    left_time = erlang:error({required, left_time}),
    room_state = erlang:error({required, room_state}),
    room_step = erlang:error({required, room_step}),
    card_num = erlang:error({required, card_num}),
    max_bet = erlang:error({required, max_bet}),
    over_time = erlang:error({required, over_time}),
    poker1 = erlang:error({required, poker1}),
    poker2 = erlang:error({required, poker2}),
    poker_list3 = [],
    poker_list4 = [],
    poker_list5 = [],
    open_list = [],
    pos_list = [],
    isbegin = erlang:error({required, isbegin})
}).
-endif.

-ifndef(CG_KEN_BET_MONEY_PB_H).
-define(CG_KEN_BET_MONEY_PB_H, true).
-record(cg_ken_bet_money, {
    usr_id = erlang:error({required, usr_id}),
    money = erlang:error({required, money}),
    unit_id = erlang:error({required, unit_id})
}).
-endif.

-ifndef(GC_KEN_BET_MONEY_PB_H).
-define(GC_KEN_BET_MONEY_PB_H, true).
-record(gc_ken_bet_money, {
    usr_id = erlang:error({required, usr_id}),
    money = erlang:error({required, money}),
    type = erlang:error({required, type}),
    pos = erlang:error({required, pos}),
    next_type = erlang:error({required, next_type}),
    next_pos = erlang:error({required, next_pos}),
    unit_id = erlang:error({required, unit_id})
}).
-endif.

-ifndef(CG_KEN_OPEN_CARD_PB_H).
-define(CG_KEN_OPEN_CARD_PB_H, true).
-record(cg_ken_open_card, {
    type = erlang:error({required, type}),
    pos = erlang:error({required, pos})
}).
-endif.

-ifndef(GC_KEN_OPEN_CARD_PB_H).
-define(GC_KEN_OPEN_CARD_PB_H, true).
-record(gc_ken_open_card, {
    type = erlang:error({required, type}),
    pos = erlang:error({required, pos}),
    poker1,
    poker2
}).
-endif.

