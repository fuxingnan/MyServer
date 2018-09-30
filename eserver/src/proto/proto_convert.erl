%%%----------------------------------------------------------------------
%%%
%%% @author: auto generate
%%% @doc: 协议id转换 (自动生成，请勿编辑!)
%%%
%%%----------------------------------------------------------------------
-module(proto_convert).
-include("wg.hrl").
-include("../src/proto/proto.hrl").
-export([id_mf_convert/1]).


id_mf_convert(0) -> proto_attr;
id_mf_convert(mod_attr) -> 0;
id_mf_convert({0, 1, _}) -> {mod_attr, proto_attr, cg_get_register};
id_mf_convert({mod_attr, cg_get_register}) -> {0, 1, 0};
id_mf_convert({0, 2, _}) -> {mod_attr, proto_attr, gc_ret_register};
id_mf_convert({mod_attr, gc_ret_register}) -> {0, 2, 0};
id_mf_convert({0, 3, _}) -> {mod_attr, proto_attr, cg_register};
id_mf_convert({mod_attr, cg_register}) -> {0, 3, 0};
id_mf_convert({0, 4, _}) -> {mod_attr, proto_attr, gc_register_ret};
id_mf_convert({mod_attr, gc_register_ret}) -> {0, 4, 0};
id_mf_convert({0, 6, _}) -> {mod_attr, proto_attr, cg_change_attr};
id_mf_convert({mod_attr, cg_change_attr}) -> {0, 6, 0};
id_mf_convert({0, 7, _}) -> {mod_attr, proto_attr, gc_change_ret};
id_mf_convert({mod_attr, gc_change_ret}) -> {0, 7, 0};
id_mf_convert({0, 8, _}) -> {mod_attr, proto_attr, gc_player_kickoff};
id_mf_convert({mod_attr, gc_player_kickoff}) -> {0, 8, 0};
id_mf_convert({0, 9, _}) -> {mod_attr, proto_attr, cg_bind_account};
id_mf_convert({mod_attr, cg_bind_account}) -> {0, 9, 0};
id_mf_convert({0, 10, _}) -> {mod_attr, proto_attr, gc_bind_account_ret};
id_mf_convert({mod_attr, gc_bind_account_ret}) -> {0, 10, 0};
id_mf_convert({0, 11, _}) -> {mod_attr, proto_attr, gc_give_money};
id_mf_convert({mod_attr, gc_give_money}) -> {0, 11, 0};
id_mf_convert({0, 12, _}) -> {mod_attr, proto_attr, cg_req_money};
id_mf_convert({mod_attr, cg_req_money}) -> {0, 12, 0};

id_mf_convert(1) -> proto_acc;
id_mf_convert(mod_acc) -> 1;
id_mf_convert({1, 1, _}) -> {mod_acc, proto_acc, cg_login};
id_mf_convert({mod_acc, cg_login}) -> {1, 1, 0};
id_mf_convert({1, 2, _}) -> {mod_acc, proto_acc, gc_login_ret};
id_mf_convert({mod_acc, gc_login_ret}) -> {1, 2, 0};
id_mf_convert({1, 3, _}) -> {mod_acc, proto_acc, cg_selectrole};
id_mf_convert({mod_acc, cg_selectrole}) -> {1, 3, 0};
id_mf_convert({1, 4, _}) -> {mod_acc, proto_acc, gc_selectrole_ret};
id_mf_convert({mod_acc, gc_selectrole_ret}) -> {1, 4, 0};
id_mf_convert({1, 5, _}) -> {mod_acc, proto_acc, cg_createrole};
id_mf_convert({mod_acc, cg_createrole}) -> {1, 5, 0};
id_mf_convert({1, 6, _}) -> {mod_acc, proto_acc, gc_createrole_ret};
id_mf_convert({mod_acc, gc_createrole_ret}) -> {1, 6, 0};
id_mf_convert({1, 7, _}) -> {mod_acc, proto_acc, cg_connected_heartbeat};
id_mf_convert({mod_acc, cg_connected_heartbeat}) -> {1, 7, 0};

id_mf_convert(2) -> proto_room;
id_mf_convert(mod_room) -> 2;
id_mf_convert({2, 1, _}) -> {mod_room, proto_room, cg_join_room};
id_mf_convert({mod_room, cg_join_room}) -> {2, 1, 0};
id_mf_convert({2, 2, _}) -> {mod_room, proto_room, gc_join_room};
id_mf_convert({mod_room, gc_join_room}) -> {2, 2, 0};
id_mf_convert({2, 3, _}) -> {mod_room, proto_room, gc_add_member};
id_mf_convert({mod_room, gc_add_member}) -> {2, 3, 0};
id_mf_convert({2, 4, _}) -> {mod_room, proto_room, cg_add_money};
id_mf_convert({mod_room, cg_add_money}) -> {2, 4, 0};
id_mf_convert({2, 5, _}) -> {mod_room, proto_room, gc_add_money};
id_mf_convert({mod_room, gc_add_money}) -> {2, 5, 0};
id_mf_convert({2, 6, _}) -> {mod_room, proto_room, gc_player_turn};
id_mf_convert({mod_room, gc_player_turn}) -> {2, 6, 0};
id_mf_convert({2, 7, _}) -> {mod_room, proto_room, cg_bet_money};
id_mf_convert({mod_room, cg_bet_money}) -> {2, 7, 0};
id_mf_convert({2, 8, _}) -> {mod_room, proto_room, gc_bet_money};
id_mf_convert({mod_room, gc_bet_money}) -> {2, 8, 0};
id_mf_convert({2, 9, _}) -> {mod_room, proto_room, gc_ret_ready};
id_mf_convert({mod_room, gc_ret_ready}) -> {2, 9, 0};
id_mf_convert({2, 10, _}) -> {mod_room, proto_room, cg_get_rank};
id_mf_convert({mod_room, cg_get_rank}) -> {2, 10, 0};
id_mf_convert({2, 11, _}) -> {mod_room, proto_room, gc_get_rank};
id_mf_convert({mod_room, gc_get_rank}) -> {2, 11, 0};
id_mf_convert({2, 12, _}) -> {mod_room, proto_room, cg_quit_room};
id_mf_convert({mod_room, cg_quit_room}) -> {2, 12, 0};
id_mf_convert({2, 13, _}) -> {mod_room, proto_room, gc_quit_room};
id_mf_convert({mod_room, gc_quit_room}) -> {2, 13, 0};
id_mf_convert({2, 14, _}) -> {mod_room, proto_room, gc_reconnect_failed};
id_mf_convert({mod_room, gc_reconnect_failed}) -> {2, 14, 0};
id_mf_convert({2, 15, _}) -> {mod_room, proto_room, cg_force_join};
id_mf_convert({mod_room, cg_force_join}) -> {2, 15, 0};
id_mf_convert({2, 16, _}) -> {mod_room, proto_room, gc_force_join};
id_mf_convert({mod_room, gc_force_join}) -> {2, 16, 0};
id_mf_convert({2, 17, _}) -> {mod_room, proto_room, cg_change_room};
id_mf_convert({mod_room, cg_change_room}) -> {2, 17, 0};
id_mf_convert({2, 18, _}) -> {mod_room, proto_room, gc_change_room};
id_mf_convert({mod_room, gc_change_room}) -> {2, 18, 0};
id_mf_convert({2, 19, _}) -> {mod_room, proto_room, cg_deleteroom};
id_mf_convert({mod_room, cg_deleteroom}) -> {2, 19, 0};
id_mf_convert({2, 20, _}) -> {mod_room, proto_room, gc_deleteroom};
id_mf_convert({mod_room, gc_deleteroom}) -> {2, 20, 0};
id_mf_convert({2, 21, _}) -> {mod_room, proto_room, gc_friend_result};
id_mf_convert({mod_room, gc_friend_result}) -> {2, 21, 0};
id_mf_convert({2, 22, _}) -> {mod_room, proto_room, gc_friend_join_result};
id_mf_convert({mod_room, gc_friend_join_result}) -> {2, 22, 0};
id_mf_convert({2, 23, _}) -> {mod_room, proto_room, gc_game_over};
id_mf_convert({mod_room, gc_game_over}) -> {2, 23, 0};
id_mf_convert({2, 24, _}) -> {mod_room, proto_room, gc_hide_loading};
id_mf_convert({mod_room, gc_hide_loading}) -> {2, 24, 0};
id_mf_convert({2, 25, _}) -> {mod_room, proto_room, gc_rank_win_money_video};
id_mf_convert({mod_room, gc_rank_win_money_video}) -> {2, 25, 0};
id_mf_convert({2, 26, _}) -> {mod_room, proto_room, cg_get_video};
id_mf_convert({mod_room, cg_get_video}) -> {2, 26, 0};
id_mf_convert({2, 27, _}) -> {mod_room, proto_room, cg_give_room_card};
id_mf_convert({mod_room, cg_give_room_card}) -> {2, 27, 0};
id_mf_convert({2, 28, _}) -> {mod_room, proto_room, gc_give_room_card};
id_mf_convert({mod_room, gc_give_room_card}) -> {2, 28, 0};

id_mf_convert(3) -> proto_chat;
id_mf_convert(mod_chat) -> 3;
id_mf_convert({3, 1, _}) -> {mod_chat, proto_chat, cg_chat};
id_mf_convert({mod_chat, cg_chat}) -> {3, 1, 0};
id_mf_convert({3, 2, _}) -> {mod_chat, proto_chat, gc_chat};
id_mf_convert({mod_chat, gc_chat}) -> {3, 2, 0};
id_mf_convert({3, 3, _}) -> {mod_chat, proto_chat, cg_face};
id_mf_convert({mod_chat, cg_face}) -> {3, 3, 0};
id_mf_convert({3, 4, _}) -> {mod_chat, proto_chat, gc_face};
id_mf_convert({mod_chat, gc_face}) -> {3, 4, 0};
id_mf_convert({3, 5, _}) -> {mod_chat, proto_chat, cg_sound};
id_mf_convert({mod_chat, cg_sound}) -> {3, 5, 0};
id_mf_convert({3, 6, _}) -> {mod_chat, proto_chat, gc_sound};
id_mf_convert({mod_chat, gc_sound}) -> {3, 6, 0};
id_mf_convert({3, 7, _}) -> {mod_chat, proto_chat, cg_voice};
id_mf_convert({mod_chat, cg_voice}) -> {3, 7, 0};
id_mf_convert({3, 8, _}) -> {mod_chat, proto_chat, gc_voice};
id_mf_convert({mod_chat, gc_voice}) -> {3, 8, 0};
id_mf_convert({3, 9, _}) -> {mod_chat, proto_chat, cg_chat_on_phone};
id_mf_convert({mod_chat, cg_chat_on_phone}) -> {3, 9, 0};
id_mf_convert({3, 10, _}) -> {mod_chat, proto_chat, gc_chat_on_phone};
id_mf_convert({mod_chat, gc_chat_on_phone}) -> {3, 10, 0};

id_mf_convert(4) -> proto_gm;
id_mf_convert(mod_gm) -> 4;
id_mf_convert({4, 1, _}) -> {mod_gm, proto_gm, cg_gm_commond};
id_mf_convert({mod_gm, cg_gm_commond}) -> {4, 1, 0};
id_mf_convert({4, 2, _}) -> {mod_gm, proto_gm, gc_gm_commond};
id_mf_convert({mod_gm, gc_gm_commond}) -> {4, 2, 0};
id_mf_convert({4, 3, _}) -> {mod_gm, proto_gm, cg_gm_player_recharge};
id_mf_convert({mod_gm, cg_gm_player_recharge}) -> {4, 3, 0};
id_mf_convert({4, 4, _}) -> {mod_gm, proto_gm, gc_gm_player_recharge};
id_mf_convert({mod_gm, gc_gm_player_recharge}) -> {4, 4, 0};

id_mf_convert(5) -> proto_kenroom;
id_mf_convert(mod_kenroom) -> 5;
id_mf_convert({5, 1, _}) -> {mod_kenroom, proto_kenroom, cg_join_ken_room};
id_mf_convert({mod_kenroom, cg_join_ken_room}) -> {5, 1, 0};
id_mf_convert({5, 2, _}) -> {mod_kenroom, proto_kenroom, gc_join_ken_room};
id_mf_convert({mod_kenroom, gc_join_ken_room}) -> {5, 2, 0};
id_mf_convert({5, 3, _}) -> {mod_kenroom, proto_kenroom, gc_add_ken_member};
id_mf_convert({mod_kenroom, gc_add_ken_member}) -> {5, 3, 0};
id_mf_convert({5, 4, _}) -> {mod_kenroom, proto_kenroom, cg_ken_add_money};
id_mf_convert({mod_kenroom, cg_ken_add_money}) -> {5, 4, 0};
id_mf_convert({5, 5, _}) -> {mod_kenroom, proto_kenroom, gc_ken_add_money};
id_mf_convert({mod_kenroom, gc_ken_add_money}) -> {5, 5, 0};
id_mf_convert({5, 6, _}) -> {mod_kenroom, proto_kenroom, gc_ken_player_turn};
id_mf_convert({mod_kenroom, gc_ken_player_turn}) -> {5, 6, 0};
id_mf_convert({5, 7, _}) -> {mod_kenroom, proto_kenroom, cg_ken_bet_money};
id_mf_convert({mod_kenroom, cg_ken_bet_money}) -> {5, 7, 0};
id_mf_convert({5, 8, _}) -> {mod_kenroom, proto_kenroom, gc_ken_bet_money};
id_mf_convert({mod_kenroom, gc_ken_bet_money}) -> {5, 8, 0};
id_mf_convert({5, 9, _}) -> {mod_kenroom, proto_kenroom, cg_ken_open_card};
id_mf_convert({mod_kenroom, cg_ken_open_card}) -> {5, 9, 0};
id_mf_convert({5, 10, _}) -> {mod_kenroom, proto_kenroom, gc_ken_open_card};
id_mf_convert({mod_kenroom, gc_ken_open_card}) -> {5, 10, 0};
id_mf_convert({V, _, _} = _Arg) when is_integer(V) ->
    ?ERROR("invalid id:~p", [_Arg]),
     error(invalid_id);
id_mf_convert({Mod, _} = _Arg) when is_atom(Mod) ->
    ?ERROR("invalid mf:~p", [_Arg]),
    error(invalid_mf).

