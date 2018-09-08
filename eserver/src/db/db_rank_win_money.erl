
-module(db_rank_win_money).                                                 
-author("276300120@qq.comm").                                           
                                                                     
-vsn("0.1").                                                          
-include("wg.hrl").                                                   
-include("db.hrl").                                                   
-include("errno.hrl").                                                
-include("const.hrl").                                                 
-include("common.hrl").                                                
-include("player.hrl").                                               
-include("room.hrl").

-export[fields_to_record/1, record_to_fields/1].                                                  
                                                                                                 
-export[create/1, update/1].
-export[load/1].
                                                                                                  
                                                                                                
-define(TABLE_RAND_WIN_MONEY, "table_rank_win_money").                                                   
-define(FULL_FIELDS_Rank_Money, [                                                                     
    "id",              "cardone",       "cardtwo",      "mypos",
    "name_list",       "image_list",    "money_list",   "pos_list",
    "table_money",     "poker_num",     "money"                                  
    ]).                                                                                          
                                                                                                  
fields_to_record([                                                                               
    Id,                CardOne,         CardTwo,        MyPos,
    NameList,          Image_List,       Money_List,    Pos_List,
    Table_Money,       Poker_Num,        Money                                                                                  
    ]) ->                                                                                         
    Data = #win_rank_data{                                                                           
        id = Id,                               
        cardone = CardOne,                 
        cardtwo = CardTwo,
        mypos = MyPos,
        name_list = NameList,                                                                 
        image_list = Image_List,                     
        money_list = Money_List,
        pos_list = Pos_List,
        table_money = Table_Money,                 
        poker_num = Poker_Num,       
        money = Money   
    },                                                                                           
    decode(Data).                                                                               
                                                                                                  
record_to_fields(Data=#win_rank_data{}) ->                                                             
    #win_rank_data{                                                                                      
        id = Id,                               
        cardone = CardOne,                 
        cardtwo = CardTwo,
        mypos = MyPos,
        name_list = NameList,                                                                 
        image_list = Image_List,                     
        money_list = Money_List,
        pos_list = Pos_List,
        table_money = Table_Money,                 
        poker_num = Poker_Num,       
        money = Money                     
    } = encode(Data),                                                                           
    [                                                                                            
    Id,                CardOne,         CardTwo,    MyPos,
    NameList,          Image_List,      Money_List,  Pos_List,
    Table_Money,       Poker_Num,       Money
    ].                                                                                            
                                                                                                  
%% @doc 创建数据 #win_rank_data                                                                      
create(Data) ->                                                                                 
    Vals = record_to_fields(Data),                                                              
    case ?DB_GAME:insert(?TABLE_RAND_WIN_MONEY, Vals) of                                                  
        {updated, 1} ->                                                                           
            ok;                                                                                   
        {error, _Reason} ->                                                                       
            ?ERROR("Create win_rank error: ~p ~p", [Data, _Reason]),
            ?C2SERR(?E_DB)                                                                        
    end.                                                                                          
                                                                                                 
                                                                   
load(Id) ->                                                                                       
    case ?DB_GAME:select(?TABLE_RAND_WIN_MONEY, ?FULL_FIELDS_Rank_Money, ["id=", db_util:encode(Id)]) of      
        {error, _Reason} ->                                                                       
            ?ERROR("Load fellow error: ~p ~p", [Id, _Reason]),                                    
            [];                                                                                   
        {selected, _Fields, [Row]} ->                                                             
            % ?DEBUG("selected fields: ~p~nrow: ~p", [_Fields, Row]),                             
            fields_to_record(Row);                                                                
        {selected, _Fields, []} ->                                                                
            %?DEBUG("Load fellow not found: ~p", [Id]),
            []                                                                                    
    end.                                                                                          
                                                                                                 
%% @doc 更新数据 #rand_win                                                                     
update(Data) ->
    %?INFO(?_U("保存一次赢金钱排行榜:~p"), [1]),
    ["id" | Fields] = ?FULL_FIELDS_Rank_Money,                                                      
    [Id | Vals] = record_to_fields(Data),                                                       
    case ?DB_GAME:update(?TABLE_RAND_WIN_MONEY, Fields, Vals, db_util:where_id(Id)) of
        {updated, 1} ->                                                                           
            ok;                                                                                   
        {updated, 0} ->                                                                          
            ok;                                                                                   
        {error, _Reason} ->                                                                       
            ?ERROR("Update fellow error: ~p ~p", [Id, _Reason]),                                  
            ?C2SERR(?E_DB)                                                                        
    end.                                                                                          
                                                                                                                                                                                                                                                           
                                                                            
decode(Data=#win_rank_data{ name_list = NameList,image_list = Image_List,money_list = Money_List,pos_list = Pos_List}) ->
    Data#win_rank_data{
        name_list = game_misc:decode_term(NameList),
        image_list = game_misc:decode_term(Image_List),
        money_list = game_misc:decode_term(Money_List),
        pos_list = game_misc:decode_term(Pos_List)
    }.

encode(Data=#win_rank_data{ name_list = NameList,image_list = Image_List,money_list = Money_List,pos_list = Pos_List}) ->
    Data#win_rank_data{
        name_list = game_misc:encode_term(NameList),
        image_list = game_misc:encode_term(Image_List),
        money_list = game_misc:encode_term(Money_List),
        pos_list = game_misc:encode_term(Pos_List)
    }.
