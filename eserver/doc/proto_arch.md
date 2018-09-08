# 消息分类
##系统类消息(0)
    cg_connected_heartbeat
    gc_connected_heartbeat
    gc_notice
    gc_updatenoticedata

    
##账户类消息(1)
    cg_login
    gc_login_ret
    cg_createrole
    gc_createrole_ret
    cg_selectrole
    gc_selectrole_ret
    cg_ask_role_data,    //ask role data
    gc_ret_role_data,    //ret role data
      
##场景信息类消息(2)
    gc_enter_scene
    cg_enter_scene_ok
    cg_req_change_scene
    gc_create_player
    gc_delete_obj
    cg_sync_pos
    gc_sync_pos
    cg_move
    gc_move
    gc_stop
    cg_req_near_list
    gc_near_playerlist
    gc_near_teamlist
    gc_create_npc,   //create npc    
    gc_playstory,    //send client playstory
    cg_playstory_over,   //send server playstory over
    cg_ask_relive,   //send ask relive
    gc_ret_relive,   //send ret relive
    gc_dropitem_info,    //send dropinfo
    cg_ask_pickup_item,  //send ask pickupitem
    gc_ret_pickup_item,  //send ret pickup item
    cg_ask_selobj_info,  //ask current select obj info
    gc_ret_selobj_info,  //send ret current select obj info
    
    gc_damageboard_info, //send damageboard info to client
    cg_open_copyscene,   //send open copyscene req to server
    gc_copyscene_invite, //send copyscene invite req to client
    cg_copyscene_invite_ret, //send copyscene invite ret to server
    gc_copyscene_result, //send copysceneresult to client
    cg_ask_copyscene_reward, //send copyscenereward to server
    gc_ret_copyscene_reward, //send copyscenereward to client
    cg_ask_copyscene_sweep,  //send copyscenesweep to server
    gc_ret_copyscene_sweep,  //send copyscenesweep to client
    gc_play_effect,  //server send player use tool
    gc_op_teleport,  //server op copyscene teleport
    gc_op_qinggongpoint, //server op copyscene qinggongpoint
    gc_scene_timescale,  // server change scene time scale
    cg_leave_copyscene,  // client leave copyscene
    gc_update_animation_state,   //update animation state
    cg_change_majorcity, //request change major city
    cg_ask_quit_game,    //ask change game selece scene
    gc_ret_quit_game,    //ret change game selece
    gc_sync_reachedscene,    //send reached scene
    gc_force_setpos, //server force set player pos
    gc_debug_my_pos, //server debug player pos
            
##玩家信息类消息(3)
    cg_combatvalue_ask,  //client ask player combatvalue from server
    gc_combatvalue_ret,  //server send player combatvalue to client
    cg_ask_pkinfo,   //ask pk info
    gc_ret_pkinfo,   //ret pk info
    cg_change_pkmodle,   //ask change pk modle
    gc_ret_change_pkmodle,   //ret change pk modle
    gc_change_pklist,    // change pklist
    cg_req_challenge,    //request pk somebody
    gc_broadcast_attr
    gc_syn_attr
    cg_user_behavior,    //client send behavior
    
    
##系统任务类消息(4)
    gc_mission_sync_missionlist
    cg_acceptmission
    gc_acceptmission_ret
    cg_completemission
    gc_completemission_ret
    cg_abandonmission
    gc_abandonmission_ret
    gc_mission_state
    gc_mission_param
    gc_mission_ignoremissionpreflag, //send ignoremissionpreflag to client
    gc_update_animation_state,   //update animation state
    cg_dailymission_update,  //ask to update dailymission
    gc_dailymission_update_ret,  //send dailymission updatedata
    
##技能(5)
    cg_skill_use
    gc_ret_use_skill,    //use skill ret
    gc_cdtime_update
    gc_skill_finish, // server skill finish
    gc_skill_study,  // server send studyinfo
    gc_syn_skillinfo,    //server syn skill info
    gc_update_scene_instactivation,  //update scene instactivation

    gc_update_hitponit,  //update hitpoint
    cg_ask_levelupskill, //ask levelupskill
    gc_attackfly,    //attak fly
    gc_update_active_fellowskill,    //update fellow active skill
    cg_equip_fellow_skill,   //equip fellow skill
    gc_equip_fellow_skill_ret,   //equip fellow skill ret
    cg_unequip_fellow_skill, //unequip fellow skill
    gc_unequip_fellow_skill_ret, //unequip fellow skill ret
    cg_levelup_fellow_skill, //levelup fellow skill
    gc_levelup_fellow_skill_ret, //levelup fellow skill ret    
    
##聊天类消息(6)
    cg_chat, //client send chat info
    gc_chat, //server send chat info
    cg_gmcommand,    //send gm command
    cg_ask_loudspeaker_pool, //client ask loudspeaker pool
    gc_ask_loudspeaker_content,  //server ask client loudspeaker content
    
##活动(7)
    cg_ask_newserveraward,   //client ask to get newserveraward
    gc_newserveraward_data,  //send newserveraward data to client
    cg_ask_dayaward, //client ask to get dayaward
    gc_dayaward_data,    //send dayaward data to client
    cg_ask_onlineaward,  //client ask to get onlineaward
    gc_onlineaward_data, //send onlineaward data to client
    cg_ask_activenessaward,  //client ask to get activenessaward
    gc_ask_activenessaward_ret,  //send activenessaward ret to client
    gc_sync_activenessaward, //sync activenessaward data to client
    cg_moneytree_askaward,   //moneytree client ask server award
    gc_moneytree_data,   //server sync moneytree data to client
    
## 美人系统(8)
    gc_belle_data
    cg_belle_close
    gc_belle_close_ret
    cg_belle_evolution
    gc_belle_evolution_ret
    cg_belle_evolutionrapid
    gc_belle_evolutionrapid_ret
    cg_belle_battle
    gc_belle_battle_ret
    cg_belle_rest
    gc_belle_rest_ret
    cg_belle_activematrix
    gc_belle_activematrix_ret
    gc_belle_active
##黑市(9)
    cg_ask_blackmarketiteminfo
    cg_buy_blackmarketitem
    gc_close_blackmarket
    gc_ret_blackmarketiteminfo
    gc_show_blackmarket
##市场(10)
    cg_ask_yuanbaoshop_open
    cg_buy_yuanbaogoods
    gc_ret_yuanbaoshop_open
    gc_server_config
    cg_buy_fashion
    cg_buy_stamina
    cg_systemshop_buy_pak.cpp
    cg_systemshop_buy
    cg_systemshop_buyback
    cg_systemshop_sell
    cg_systemshop_view
    cg_wear_fashion
    gc_systemshop_merchandiselist
    cg_systemshop_view
    cg_systemshop_buy
    cg_systemshop_buyback
    cg_systemshop_sell
    gc_systemshop_merchandiselist
##公会(11)
    cg_guild_req_list,   //guild client req all server guild info
    gc_guild_ret_list,   //guild server ret all server guild info
    cg_guild_req_info,   //guild client req self guild info
    gc_guild_ret_info,   //guild server ret self guild info
    cg_guild_req_change_notice,  //guild client req change guild notice
    cg_guild_create, //guild client req create guild
    gc_guild_create, //guild server ret create guild
    cg_guild_join,   //guild client req join guild
    gc_guild_join,   //guild server ret join guild
    cg_guild_leave,  //guild client req leave guild
    gc_guild_leave,  //guild server ret leave guild
    cg_guild_kick,   //guild client req kick guild
    cg_guild_job_change, //guild client req change member job
    cg_guild_approve_reserve,    //guild client req approve reserve member
    cg_guild_req_levelup,    //guild client req guild level up
    gc_guild_ret_levelup,    //guild server ret guild level up
## 物品(12)
    gc_updateitem
    cg_use_item
    cg_equip_item
    cg_unequip_item
    cg_throw_item
    cg_equip_enchance,   //client send equip enchance
    cg_equip_star,   //client send equip star
    gc_equip_enchance_ret,   //server send equip enchance result
    gc_equip_star_ret,   //server send equip star result
    gc_show_equipremind, // server send client equipremind
    cg_backpack_unlock,  //unlock backpack
    gc_backpack_resize,  //update backpack size
    gc_use_item_ret, //useitem ret
    
##邮件(13)
    gc_mail_update,  //server update mail
    gc_mail_delete,  //server del mail
    cg_mail_send,    //client send mail
    cg_mail_operation,   //client op mail
    
##坐骑(14)
    gc_mountcollected_flag,  //sync mountcollected flag
    gc_mount_data,   //sync mount status
    cg_mount_mark,   //client send mount markautomoutid
    gc_mount_mark_ret,   //server send mount markautomoutid ret
    cg_mount_mount,  //client send mount ride mount
    cg_mount_unmount,    //client send mount unmount
    
  
##社交(15)
    cg_addfriend,    //client req add friend
    gc_addfriend,    //server ret add friend
    cg_delfriend,    //client req del friend
    cg_req_friend_userinfo,  //client req update friend userinfo
    gc_ret_friend_userinfo,  //server ret update friend userinfo
    gc_delfriend,    //server ret del friend
    gc_notice_added_friend,  //server notice client be added by other player
    gc_syc_friend_state, //server syc one friend state
    gc_syc_friend_info,  //server syc one friend info
    gc_syc_full_friend_list, //server syc full friends list
    cg_addblacklist, //client req add blacklist
    gc_addblacklist, //server ret add blacklist
    gc_syc_full_black_list,  //server syc full black list
    cg_delblacklist, //client req del blacklist
    gc_delblacklist, //server ret del blacklist
    cg_findplayer,   //client req find player
    gc_findplayer,   //server ret find player result
    gc_synseltraget_attr,    //server syn selectobj attr
    
##组队(16)
    cg_req_team_invite
    cg_req_team_join
    cg_req_team_leave
    cg_req_team_kick_member
    cg_req_team_change_leader
    gc_team_leave
    gc_team_sync_teaminfo
    gc_team_sync_memberinfo
    gc_join_team_invite
    cg_join_team_invite_result
    gc_join_team_request
    cg_join_team_request_result
##称号(17)
    gc_update_all_titleinvestitive,  //server update all titleinvestitive
    cg_active_title, //client active title
    cg_delete_title, //client delete title
    gc_gain_title,   //server gain title
    gc_delete_title, //server delete title
    gc_active_title, //server active title
    gc_sync_activetitle, //server active title
##世界boss(18)
    gc_worldboss_dead,   //notify world boss is dead
    cg_worldboss_teamlist_req,   //request world boss team list
    gc_worldboss_teamlist,   //world boss team rank list
    gc_worldboss_open,   //world boss is ready
    cg_worldboss_challenge,  //request challenge boss team
    cg_worldboss_join,   //request kill world boss

##宠物(19)
    gc_update_fellow,    //send update fellow
    gc_create_fellow,    //create fellow
    cg_call_fellow,  //call fellow
    gc_call_fellow_ret,  //call fellow ret
    cg_uncall_fellow,    //
    gc_uncall_fellow_ret,    //uncall fellow ret
    cg_lock_fellow,  //lock fellow
    cg_unlock_fellow,    //unlock fellow
    cg_resolve_fellow,   //resolve fellow
    gc_resolve_fellow_ret,   //resolve fellow ret
    cg_ask_gain_fellow,  //client ask gain fellow
    gc_ask_gain_fellow_ret,  //ask gain fellow ret
    gc_update_gain_fellow_count, //update gain fellow count
    cg_fellow_star,  //fellow star
    gc_fellow_star_ret,  //fellow star ret
    cg_fellow_enchance,  //fellow enchance
    gc_fellow_enchance_ret,  //fellow enchance ret
    cg_fellow_apply_point,   //fellow apply point
    gc_fellow_apply_point_ret,   //fellow apply point ret
    
##排行榜(20)
    gc_challenge_mydata, //challenge rank's data
    cg_challengeranklist_req,    //request challenge rank list
    gc_challengeranklist,    // challenge rank list
    gc_challenge_reward, //challenge rank reward
    gc_challenge_history,    //challenge history
    cg_ask_rank, // ask rank to server
    gc_ret_rank, // ret rank to client
    
## 引导(21)
    gc_ui_newplayerguide,    // server send client newplayerguide
    gc_play_modelsotry,  //server send client 3d story
    gc_playshandianlianeffect,   //shandianlian effect
    gc_ui_operation, // ui operation
## 其他(22)
    gc_countdown,    //show countdown
    gc_usertip,  //server send client tip
    gc_play_sounds,  //server playsounds
    cg_scene_changeinst, //client send change channle request
    gc_sync_copyscenenumber, //sync copyscenenumber to client
    cg_copyscenereset,   //sync copyscenereset to client
    cg_change_showfashion,   //client change showfashion
    gc_change_showfashion,   //server change showfashion
    cg_use_livingskill,  //client use livingskill formula
    gc_create_snare, //create snareobj
    cg_preliminary_applyguildwar,    //apply preliminary guildwar
    cg_ask_preliminary_warinfo,  //ask  preliminary war info
    gc_ret_preliminary_warinfo,  //ret preliminary war info
    gc_syn_torch_value,  //syn torch value
    cg_ask_torch_value,  //ask torch value
    gc_ask_startguildwar,    //ask  star war
    cg_ret_startwar, //ret star war
    gc_show_preliminary_warret,  //show preliminary war ret info
    cg_qiankundai_combine,   //client combine qiankundai formula
    gc_qiankundai_product,   //server send combine product
    cg_active_fellow_skill,  //client ask active fellow skill
    cg_buy_stamina,  //client buy stamina
    cg_fightguildwarpoint,   //client fight guildwar point
    cg_ask_finalguildwargroupinfo,   //client ask finalguildwar groupinfo
    cg_ask_finalguildwarpointinfo,   //client ask finalguildwar pointinfo
    gc_ret_finalguildwargroupinfo,   //ret  finalguildwar group info
    gc_ret_finalguildwarpointinfo,   //ret finalguildwar point info
    gc_update_stamina_time,  //server sync stamina remain time
    gc_login_queue_status,   //login queue status
    cg_ask_yuanbaoshop_open, //client ask yuanbaoshop open
    gc_ret_yuanbaoshop_open, //server ret yuanbaoshop open
    gc_show_blackmarket, //server show yuanbaoshop blackmarket
    gc_openfunction, //server open function
    cg_ask_otherrole_data,   //client ask other player data
    gc_ret_otherrole_data,   //server send other plater data to client
    cg_ask_hide_fellow,  //client ask hide fellow
    cg_ask_show_fellow,  //client ask show fellow
    gc_show_itemremind,  //server remind new item
    gc_ret_put_gem,  //server ret put gem
    cg_cypay_success,    //client send pay success
    cg_visit_swordsman,  //client send  swordsman
    cg_swordsman_levelup,    //client send  swordsman levelup
    cg_buy_swordsman,    //client send  buy swordsman
    cg_equip_swordsman,  //client send equipswordsman
    cg_unequip_swordsman,    //client send unequipswordsman
    gc_update_swordsman, //server update swordsman
    gc_update_swordsman_visitstate,  //server update swordsmanstate
    gc_activitynotice,   //server send activitynotice
    cg_fellow_reset_point,   //client ask reset fellow point
    gc_ret_fellow_reset_point,   //server ret reset fellow point
    cg_req_powerup,  //client power up
    gc_res_powerup,  //server send power up
    gc_powerup_list, //server send power up list
    gc_buy_guildgoods,   //server send buy guildshop goods result
    gc_sync_awardtable,  //server send onlineawardtable to client
    cg_req_randomname = 390,   //client request random name
    gc_ret_randomname,   //server ret randomname
    gc_guild_newreserve, //server send guild chief and vice-chief that their guild have new reserver member
    gc_show_skillname,   //server show skill name
    cg_ask_curguildwartype,  //ask current guidwartype
    gc_ret_curguildwartype,  //ret current guidwartype
    cg_set_death_push,   //set death push flag
    gc_swordsmanpack_resize, //update swordsmanpack size,éïò»´îïûï¢°üãû×ö´íáë
    gc_ret_visit_swordsman,  //ret_visitswordsman
    gc_ret_levelup_swordsman,    //return levelup
    cg_req_marrage,  //client ask about marrage
    gc_ret_marrage,  //server ret about marrage
    cg_ask_challengeguildwar,    //ask challengeguildwar
    cg_lock_swordsman,   //client send lockswordsman
    cg_unlock_swordsman, //client send unlockswordsman
    cg_ask_huashanpvp_state, //request state
    gc_syn_loverinfo,    //server syn lover info
    cg_sns_invite_code,  //sns invite code
    gc_sns_invite_code_response, //sns invite code response
    gc_sns_active_show,  //sns active show
    cg_sns_share,    //sns share ok
    gc_push_notification,    //server send noticedata to client
    gc_show_useitemremind,   // server send client useitemremind
    cg_ask_newonlineaward,   //client ask to get newonlineaward
    gc_newonlineaward_data,  //send newonlineaward data to client
    gc_sync_newonlineawardtable, //server send onlineawardtable to client
    cg_ask_gain_10_fellow,   //client ask gain 10 fellow
    gc_ask_gain_10_fellow_ret,   //ask gain 10 fellow ret
    cg_guild_invite, //invite player join main player's guild
    gc_guild_invite_confirm, //receive invite guild confirm
    cg_guild_invite_confirm, //send invite guild confirm
    gc_sync_pay_activity_data,   //sync payment activity data
    cg_ask_pay_activity_prize,   //ask pay activity prize
    gc_ask_pay_activity_prize_ret,   //ask pay activity prize ret
    cg_ask_lock_title,   //client ask lock title
    gc_ret_lock_title,   //server ret lock title
    cg_request_cdkey,    //client use cdkey
    cg_ask_update_storagepack,   //client ask update storagepack
    gc_update_storagepack,   //server update storagepack
    gc_ask_update_storagepack_ret,   //server ask update storagepack ret
    cg_put_item_storagepack, //storagepack put item
    gc_put_item_storagepack_ret, //storagepack put item ret
    cg_take_item_storagepack,    //storagepack take item
    gc_take_item_storagepack_ret,    //storagepack take item ret
    cg_storagepack_unlock,   //storagepack ask unlock
    cg_req_changename,   //req_changename
    gc_ret_changename,   //ret_changename
    gc_worldboss_somechall_me,   //answer_worldboss_challenge
    cg_worldboss_chall_response, //response battle
    gc_sync_master_skill_name,   //sync master skill name
    gc_sync_copysceneextranumber,    //sync copysceneextranumber to client
    gc_changename,   //changename
    cg_ask_blackmarketiteminfo,  //ask blackmarket item info
    gc_ret_blackmarketiteminfo,  //ret blackmarket item info
    cg_buy_blackmarketitem,  //buy blackmarket item
    gc_close_blackmarket,    //close blackmarket item
    gc_worldboss_challege_res,   //worldboss challenge
    cg_req_huashan_pkinfo,   //huashan pk info  request
    gc_ret_huashan_pkinfo,   //huashan pkinfo
    gc_play_yanhua,  //yanhua
    gc_create_yanhua,    //create yanhuaobj
    gc_syc_full_hate_list,   //server syc full hate list
    cg_delhatelist,  //client req del hatelist
    gc_delhatelist,  //server ret del hatelist
    cg_ask_trail,    //client ask trail player
    gc_ret_trail,    //server ret trail player
    gc_addhatelist,  //server add hate list
    gc_update_def_title, //update def title
    gc_server_config,    //server config
    cg_guild_join_otherplayer,   //guild client req join otherplayer guild
    gc_open_sharewindow, //server send opensharewindow to client
    cg_mastershop_buy,   //client buy mastershop goods
    gc_mastershop_buy,   //server send buy mastershop goods result
    gc_update_rechargestate, //server send isenable recharge
    cg_ask_isrecharge_enable,    //client req is reacharge enable
    cg_ask_guildwildwar, //ask guildwildwar
    cg_ask_enemyguildinfo,   //ask enemy guild info
    gc_ret_enemyguildinfo,   //ret enemy guild info
    gc_ret_iswildenemy2user, //isenemy2user
    gc_restaurant_visitfriendinfo,   //server send visit friend info
    gc_showpknotice, //show pk notice
    gc_guildactivity_bossdata,   //update guildactivity ui
    cg_ask_new7dayonlineaward,   //client ask to get new7dayonlineaward
    gc_new7dayonlineaward_data,  //send new7dayonlineaward data to client
    gc_sync_new7dayonlineawardtable, //server send new7dayonlineawardtable to client
    gc_serverflags,  //server send flags when client login
    cg_ask_specialaward, //client ask for specialaward
    gc_today_first_login,    //server send today first login
    
## 华山副本(23)
    cg_huashan_pvp_register, //regiser for huashan pvp
    cg_huashan_pvp_memberlist,   //huashan pvp member list request
    gc_huashan_pvp_memberlist,   //huashan pvp member list
    gc_huashan_pvp_state,    //huashan pvp state
    gc_huashan_pvp_selfposition, //huashan pvp self position
    gc_huashan_pvp_showsearch,   //huashan pvp search opponent
    gc_huashan_pvp_opponentview, //huashan pvp opponent view
    gc_huashan_pvp_assist_state, //huashan pvp assist disable or enable
    cg_huashan_assist_req,   //huashan pvp assist request
## 切磋副本(24)
    cg_duel_request, //request duel somebody
    gc_duel_requestu,    //somebody request duel with u
    cg_duel_response,    //response duel
    gc_duel_state,   //duel state
## 佣兵(25)
    cg_mercenary_list_req,   //request mercenary list
    gc_mercenary_list_res,   //response mercenary list
    gc_mercenary_lefttimes,  //mercenary left times
    gc_mercenary_employlist, //response mercenary employed  list
    cg_mercenary_req,    //request mercenary
## 酒馆(26)
    gc_restaurant_update,    // server send restaurant data
    gc_restaurant_destupdate,    // server send restaurant desk data
    gc_restaurant_levelupdate,   // server send restaurant level data
    cg_restaurant_preparefood,   //client send prepare food data
    cg_restaurant_billingall,    //client send billing
    cg_restaurant_finishprepare, //client send finish prepare
    cg_restaurant_activedesk,    //client send active dest
    cg_restaurant_visitfriend,   //
##师门(27)
    cg_master_req_list,  //client req all server master info
    gc_master_ret_list,  //server ret all server master info
    cg_master_req_info,  //client req master info
    gc_master_ret_info,  //server ret master info
    cg_master_req_change_notice, //client req change master notice
    cg_master_create,    //client req create master
    gc_master_create,    //server ret create master
    cg_master_join,  //client req join master
    gc_master_join,  //server ret join master
    cg_master_leave, //client req leave master
    gc_master_leave, //server ret leave master
    cg_master_kick,  //client req kick master
    gc_master_kick,  //server ret kick master
    cg_master_approve_reserve,   //client req approve reserve member
    gc_master_approve_reserve,   //server ret approve reserve member
    cg_master_active_skill,  //client req learn skill
    gc_master_learn_skill,   //server ret learn skill
    cg_master_forget_skill,  //client req forget skill
    gc_master_forget_skill,  //server ret forget skill
    cg_master_learn_skill,   //client req active skill
    gc_master_active_skill,  //server ret active skill
    
    
   
    
    
    
    
    
    
        
    
    
    
    
    
    
    
    
    
    
    
      



